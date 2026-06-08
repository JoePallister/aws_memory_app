const API_URL = "https://vy06463wtl.execute-api.eu-north-1.amazonaws.com";

const status = document.getElementById("status");
const container = document.getElementById("cards-container");

const userId = localStorage.getItem("user_id");

if (!userId) {
  window.location.href = "index.html";
}

async function loadCards() {
  status.textContent = "Loading cards...";

  try {
    const res = await fetch(`${API_URL}/cards/${userId}`);
    const data = await res.json();

    renderCards(data);

    status.textContent = `Loaded ${data.length ?? 0} cards`;
  } catch (err) {
    status.textContent = `Error: ${err}`;
  }
}

function renderCards(cards) {
  container.innerHTML = "";

  if (!cards || cards.length === 0) {
    container.innerHTML = "<p>No cards yet</p>";
    return;
  }

  cards.forEach(card => {
    const div = document.createElement("div");
    div.className = "card";
    div.innerHTML = `
      <strong>Front:</strong> ${card.card_front}<br/>
      <strong>Back:</strong> ${card.card_back}
    `;
    container.appendChild(div);
  });
}

document.getElementById("load-cards")
  .addEventListener("click", loadCards);

document.getElementById("card-form")
  .addEventListener("submit", async (e) => {
    e.preventDefault();

    const payload = {
      user_id: userId,
      card_front: document.getElementById("front").value,
      card_back: document.getElementById("back").value,
    };

    status.textContent = "Creating card...";

    try {
      const res = await fetch(`${API_URL}/cards`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });

      const text = await res.text();
      status.textContent = text;

      if (res.ok) {
        e.target.reset();
        loadCards();
      }
    } catch (err) {
      status.textContent = `Error: ${err}`;
    }
  });

loadCards();