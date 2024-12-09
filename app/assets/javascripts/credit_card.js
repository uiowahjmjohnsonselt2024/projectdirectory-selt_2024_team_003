// app/javascript/packs/credit_card.js
document.addEventListener("DOMContentLoaded", () => {
  const cardInput = document.querySelector(".credit-card-input");

  if (cardInput) {
    cardInput.addEventListener("input", (e) => {
      let value = e.target.value.replace(/\D/g, ""); // Remove all non-digit characters
      value = value.substring(0, 16); // Limit to 16 digits
      e.target.value = value.replace(/(\d{4})(?=\d)/g, "$1 "); // Insert space after every 4 digits
    });
  }
});
