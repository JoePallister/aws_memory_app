const { API_URL } = window.CONSTANTS || {};

const status = document.getElementById("status");
const container = document.getElementById("cards-container");
const MODE = document.body.dataset.mode || "all";

const cardForm = document.getElementById("card-form");

const token = localStorage.getItem("access_token");

if (!token) {
  window.location.href = "index.html";
}

async function loadCards() {
  status.textContent = "Loading cards...";

  try {
    let url = `${API_URL}/cards`;

    if (MODE === "due") {
      url += "?only_due=true";
    }

    const res = await fetch(url, {
      headers: {
        Authorization: `Bearer ${token}`
      }
    });
    const data = await res.json();
    console.log("API RESPONSE:", data);

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

    let buttonsHtml = "";

    if (MODE === "due") {
      buttonsHtml = `
        <div class="review-buttons">
          <button class="correct-btn" data-card-id="${card.card_id}">
            Correct
          </button>
          <button class="incorrect-btn" data-card-id="${card.card_id}">
            Incorrect
          </button>
        </div>
      `;
    }

    div.innerHTML = `
      <h3>Front: ${card.card_front}</h3>

      <p><strong>Back:</strong> ${card.card_back}</p>

      <hr>

      <p><strong>User ID:</strong> ${card.user_id}</p>
      <p><strong>Card ID:</strong> ${card.card_id}</p>
      <p><strong>Last reviewed:</strong> ${card.last_reviewed_at ?? "Never"}</p>
      <p><strong>Difficulty factor:</strong> ${card.difficulty_factor}</p>
      <p><strong>Review interval:</strong> ${card.review_interval}</p>
      <p><strong>Next review time:</strong> ${card.next_review_time ?? "Not scheduled"}</p>

      ${buttonsHtml}
    `;

    container.appendChild(div);
  });
}

document.getElementById("load-cards")
  .addEventListener("click", loadCards);

if (cardForm) {
  cardForm.addEventListener("submit", async (e) => {
    e.preventDefault();

  const payload = {
      card_front: document.getElementById("front").value,
      card_back: document.getElementById("back").value,
    };

    status.textContent = "Creating card...";

    try {
      const res = await fetch(`${API_URL}/cards`, {
        method: "POST",
        headers: { 
          Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
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
}

container.addEventListener("click", async (e) => {
  if (
    !e.target.classList.contains("correct-btn") &&
    !e.target.classList.contains("incorrect-btn")
  ) {
    return;
  }

  const cardId = e.target.dataset.cardId;

  const increment = e.target.classList.contains("correct-btn")
    ? 1
    : -1;

  status.textContent = "Updating card...";

  try {
    const res = await fetch(`${API_URL}/cards/${cardId}`, {
      method: "PATCH",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        interval_increment: increment
      }),
    });

    const text = await res.text();
    status.textContent = text;

    if (res.ok) {
      loadCards();
    }
  } catch (err) {
    status.textContent = `Error: ${err}`;
  }
});

loadCards();