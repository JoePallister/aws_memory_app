const { COGNITO_DOMAIN, CLIENT_ID, REDIRECT_URI } = window.CONSTANTS || {};

// 1. Extract code from URL
const params = new URLSearchParams(window.location.search);
const code = params.get("code");

if (!code) {
  document.body.innerText = "No auth code found";
  throw new Error("Missing code");
}

// 2. Exchange code for tokens
async function exchangeCodeForToken() {
  const body = new URLSearchParams({
    grant_type: "authorization_code",
    client_id: CLIENT_ID,
    code: code,
    redirect_uri: REDIRECT_URI,
  });

  const res = await fetch(`${COGNITO_DOMAIN}/oauth2/token`, {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body,
  });

  if (!res.ok) {
    const err = await res.text();
    throw new Error(err);
  }

  const data = await res.json();

  // 3. Store tokens
  localStorage.setItem("access_token", data.access_token);
  localStorage.setItem("id_token", data.id_token);
  localStorage.setItem("refresh_token", data.refresh_token);

  // 4. Redirect into app
  window.location.href = "/cards.html";
}

exchangeCodeForToken().catch(err => {
  document.body.innerText = "Login failed: " + err.message;
});