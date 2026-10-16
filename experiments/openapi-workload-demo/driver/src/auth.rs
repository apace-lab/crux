//! Pluggable auth: the two-user seed is the only per-app manual input besides the base
//! URL. The seed is a scheme plus the two users' credential strings, selected by
//! `CRUX_AUTH_SCHEME` / `CRUX_USER_A` / `CRUX_USER_B`. Each request for a user is decorated
//! with one or more headers produced by `headers_for`, so the cross-user replay stays
//! auth-agnostic.
//!
//! Supported schemes (CRUX_AUTH_SCHEME, case-insensitive on the leading word):
//!   * `Bearer`              -> `Authorization: Bearer <cred>`         (default)
//!   * `Basic`               -> `Authorization: Basic base64(<cred>)`  where cred = "id:secret"
//!   * `Header:<HeaderName>` -> `<HeaderName>: <cred>`                 (custom header token)
//!   * `Cookie:<CookieName>` -> `Cookie: <CookieName>=<cred>`          (session-cookie auth)
//!   * any other word W      -> `Authorization: W <cred>`             (e.g. atuin's `Token`)
//!
//! For `Basic`, the per-user credential is the literal `email:password` (OpenObserve's
//! HTTP Basic). For `Cookie`, the per-user credential is the session value obtained by the
//! operator's one-time login seed (the same way atuin's session token was seeded).

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum AuthMode {
    /// `Authorization: Bearer <cred>`
    Bearer,
    /// `Authorization: Basic base64(<cred>)`, cred is "user:pass".
    Basic,
    /// `Authorization: <scheme> <cred>` for an arbitrary scheme word (Token, apiKey, ...).
    Scheme(String),
    /// `<header>: <cred>` with no scheme prefix (custom header token).
    Header(String),
    /// `Cookie: <name>=<cred>` (session-cookie auth).
    Cookie(String),
}

impl AuthMode {
    /// Parse the `CRUX_AUTH_SCHEME` seed word into a mode.
    pub fn parse(scheme: &str) -> AuthMode {
        let scheme = scheme.trim();
        if let Some(rest) = scheme.strip_prefix("Header:").or_else(|| scheme.strip_prefix("header:")) {
            return AuthMode::Header(rest.trim().to_string());
        }
        if let Some(rest) = scheme.strip_prefix("Cookie:").or_else(|| scheme.strip_prefix("cookie:")) {
            return AuthMode::Cookie(rest.trim().to_string());
        }
        match scheme.to_ascii_lowercase().as_str() {
            "bearer" => AuthMode::Bearer,
            "basic" => AuthMode::Basic,
            "" => AuthMode::Bearer,
            _ => AuthMode::Scheme(scheme.to_string()),
        }
    }
}

pub struct Auth {
    pub mode: AuthMode,
    pub user_a: String,
    pub user_b: String,
}

impl Auth {
    pub fn from_env() -> Auth {
        let scheme = std::env::var("CRUX_AUTH_SCHEME").unwrap_or_else(|_| "Bearer".into());
        Auth {
            mode: AuthMode::parse(&scheme),
            user_a: std::env::var("CRUX_USER_A").unwrap_or_else(|_| "alice".into()),
            user_b: std::env::var("CRUX_USER_B").unwrap_or_else(|_| "bob".into()),
        }
    }

    /// The HTTP header(s) that authenticate a request as `cred`'s owner.
    pub fn headers_for(&self, cred: &str) -> Vec<(String, String)> {
        match &self.mode {
            AuthMode::Bearer => vec![("Authorization".into(), format!("Bearer {cred}"))],
            AuthMode::Basic => {
                vec![("Authorization".into(), format!("Basic {}", base64_encode(cred.as_bytes())))]
            }
            AuthMode::Scheme(s) => vec![("Authorization".into(), format!("{s} {cred}"))],
            AuthMode::Header(h) => vec![(h.clone(), cred.to_string())],
            AuthMode::Cookie(name) => vec![("Cookie".into(), format!("{name}={cred}"))],
        }
    }

    pub fn headers_a(&self) -> Vec<(String, String)> {
        self.headers_for(&self.user_a)
    }
    pub fn headers_b(&self) -> Vec<(String, String)> {
        self.headers_for(&self.user_b)
    }

    /// A short principal label for trace/marker use: for Basic/Cookie the credential is
    /// "id:secret" or an opaque session, so take the part before the first ':'.
    pub fn label_a(&self) -> String {
        principal_label(&self.user_a)
    }
    pub fn label_b(&self) -> String {
        principal_label(&self.user_b)
    }
}

fn principal_label(cred: &str) -> String {
    cred.split(':').next().unwrap_or(cred).to_string()
}

/// Standard base64 (RFC 4648), used for HTTP Basic. Kept local so the driver has no extra
/// dependency.
pub fn base64_encode(input: &[u8]) -> String {
    const TABLE: &[u8; 64] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    let mut out = String::with_capacity((input.len() + 2) / 3 * 4);
    for chunk in input.chunks(3) {
        let b0 = chunk[0] as u32;
        let b1 = *chunk.get(1).unwrap_or(&0) as u32;
        let b2 = *chunk.get(2).unwrap_or(&0) as u32;
        let n = (b0 << 16) | (b1 << 8) | b2;
        out.push(TABLE[((n >> 18) & 63) as usize] as char);
        out.push(TABLE[((n >> 12) & 63) as usize] as char);
        out.push(if chunk.len() > 1 { TABLE[((n >> 6) & 63) as usize] as char } else { '=' });
        out.push(if chunk.len() > 2 { TABLE[(n & 63) as usize] as char } else { '=' });
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn base64_matches_known_vectors() {
        assert_eq!(base64_encode(b""), "");
        assert_eq!(base64_encode(b"f"), "Zg==");
        assert_eq!(base64_encode(b"fo"), "Zm8=");
        assert_eq!(base64_encode(b"foo"), "Zm9v");
        assert_eq!(base64_encode(b"foob"), "Zm9vYg==");
        assert_eq!(base64_encode(b"fooba"), "Zm9vYmE=");
        assert_eq!(base64_encode(b"foobar"), "Zm9vYmFy");
        // the canonical HTTP Basic example "Aladdin:open sesame"
        assert_eq!(base64_encode(b"Aladdin:open sesame"), "QWxhZGRpbjpvcGVuIHNlc2FtZQ==");
    }

    #[test]
    fn bearer_is_default_and_builds_header() {
        let a = Auth { mode: AuthMode::parse("Bearer"), user_a: "alice".into(), user_b: "bob".into() };
        assert_eq!(a.headers_a(), vec![("Authorization".into(), "Bearer alice".into())]);
        assert_eq!(AuthMode::parse(""), AuthMode::Bearer);
    }

    #[test]
    fn basic_encodes_user_colon_pass() {
        let a = Auth {
            mode: AuthMode::parse("Basic"),
            user_a: "root@example.com:Complexpass#123".into(),
            user_b: "bob@example.com:Bobpass#123".into(),
        };
        let h = a.headers_a();
        assert_eq!(h[0].0, "Authorization");
        assert_eq!(
            h[0].1,
            format!("Basic {}", base64_encode(b"root@example.com:Complexpass#123"))
        );
        // principal label strips the password half
        assert_eq!(a.label_a(), "root@example.com");
        assert_eq!(a.label_b(), "bob@example.com");
    }

    #[test]
    fn custom_header_token_has_no_scheme_prefix() {
        let a = Auth { mode: AuthMode::parse("Header:X-Api-Key"), user_a: "AKEY".into(), user_b: "BKEY".into() };
        assert_eq!(a.mode, AuthMode::Header("X-Api-Key".into()));
        assert_eq!(a.headers_a(), vec![("X-Api-Key".into(), "AKEY".into())]);
    }

    #[test]
    fn cookie_mode_sets_named_cookie() {
        let a = Auth { mode: AuthMode::parse("Cookie:session_id"), user_a: "SESSA".into(), user_b: "SESSB".into() };
        assert_eq!(a.mode, AuthMode::Cookie("session_id".into()));
        assert_eq!(a.headers_b(), vec![("Cookie".into(), "session_id=SESSB".into())]);
    }

    #[test]
    fn arbitrary_scheme_word_passes_through() {
        // atuin uses `Token <session>`; kellnr's cargo token is the raw value in Authorization.
        let a = Auth { mode: AuthMode::parse("Token"), user_a: "sess_a".into(), user_b: "sess_b".into() };
        assert_eq!(a.headers_a(), vec![("Authorization".into(), "Token sess_a".into())]);
    }
}
