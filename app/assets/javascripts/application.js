//= require jquery
//= require actioncable
//= require_tree .

document.addEventListener("DOMContentLoaded", () => {
    const inventoryPage = document.getElementById("inventory-page");

    // Ensure the code only runs on the inventory page
    if (!inventoryPage) return;

    const modal = document.getElementById("skin-stats-modal");
    const statsContainer = document.getElementById("skin-stats");

    // Show stats modal
    window.showSkinStats = (skinId) => {
        const skinElement = document.querySelector(`.skin-item[data-skin-id='${skinId}']`);
        const skinData = JSON.parse(skinElement.getAttribute("data-skin"));

        // Populate modal with stats
        statsContainer.innerHTML = `
      <p><strong>Archetype:</strong> ${skinData.archetype}</p>
      <p><strong>Health:</strong> ${skinData.health}</p>
      <p><strong>Mana:</strong> ${skinData.mana}</p>
      <p><strong>Attack:</strong> ${skinData.attack}</p>
      <p><strong>Special Attack:</strong> ${skinData.special_attack}</p>
      <p><strong>Defense:</strong> ${skinData.defense}</p>
      <p><strong>Special Defense:</strong> ${skinData.special_defense}</p>
      <p><strong>IQ:</strong> ${skinData.iq}</p>
      <p><strong>Level:</strong> ${skinData.level}</p>
      <p><strong>Experience:</strong> ${skinData.experience}</p>
    `;

        modal.style.display = "block";
    };

    // Close modal
    window.closeModal = () => {
        modal.style.display = "none";
    };

    // Prevent stats modal from showing when buttons are clicked
    document.querySelectorAll('.set-current-button, .remove-skin-button').forEach((button) => {
        button.addEventListener('click', (event) => {
            event.stopPropagation();
        });
    });

    // Close modal when clicking outside
    window.onclick = (event) => {
        if (event.target === modal) {
            modal.style.display = "none";
        }
    };
});
