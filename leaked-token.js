// Deliberately leaked tokens for scanner testing
// Tests all GitHub token formats from question 3

// Classic PAT (ghp_)
const GITHUB_TOKEN = "ghp_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef12345678";

// Fine-grained PAT (github_pat_)
const FINE_GRAINED_PAT = "github_pat_11AAAAAA0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";

// OAuth access token (gho_)
const OAUTH_TOKEN = "gho_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef12345678";

// App installation token (ghs_)
const APP_TOKEN = "ghs_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef12345678";

// User-to-server token (ghu_)
const USER_SERVER_TOKEN = "ghu_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef12345678";

// Refresh token (ghr_)
const REFRESH_TOKEN = "ghr_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef12345678";

// Token in a config object (realistic pattern)
const config = {
  apiUrl: "https://api.github.com",
  token: "ghp_RealWorldLeakedToken1234567890abcdefghij",
  repo: "org/private-repo"
};

// Token in a fetch call (realistic pattern)
fetch("https://api.github.com/repos/org/repo/issues", {
  headers: {
    "Authorization": "token ghp_AnotherLeakedPAT567890abcdefghijklmnop",
    "Accept": "application/vnd.github.v3+json"
  }
});

// Token in environment variable assignment
process.env.GH_TOKEN = "github_pat_22BBBBBB0yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy";