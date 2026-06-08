const API_URL = "https://vy06463wtl.execute-api.eu-north-1.amazonaws.com";

const form = document.getElementById("card-form");
const status = document.getElementById("status");

form.addEventListener("submit", async (event) => {
  event.preventDefault();

  const payload = {
    user_id: document.getElementById("user_id").value,
    card_front: document.getElementById("front").value,
    card_back: document.getElementById("back").value,
  };

  status.textContent = "Creating card...";

  try {
    const response = await fetch(`${API_URL}/cards`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });

    const body = await response.text();

    status.textContent =
      `Status: ${response.status}\n\n` +
      body;

    if (response.ok) {
      form.reset();
      document.getElementById("user_id").value = payload.user_id;
    }
  } catch (error) {
    status.textContent = `Request failed:\n\n${error}`;
  }
});