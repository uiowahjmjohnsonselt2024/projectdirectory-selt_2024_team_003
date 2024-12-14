document.addEventListener("DOMContentLoaded", () => {
    const inventoryPage = document.getElementById("inventory-page");

    // Ensure the code only runs on the inventory page
    if (!inventoryPage) return;

    const modals = {
        skin: document.getElementById("skin-stats-modal"),
        weapon: document.getElementById("weapon-stats-modal"),
        consumable: document.getElementById("consumable-stats-modal"),
    };

    const containers = {
        skin: document.getElementById("skin-stats"),
        weapon: document.getElementById("weapon-stats"),
        consumable: document.getElementById("consumable-stats"),
    };

    const showModal = (type, content) => {
        containers[type].innerHTML = content;
        modals[type].style.display = "block";
    };

    const closeModal = () => {
        Object.values(modals).forEach(modal => (modal.style.display = "none"));
    };

    window.showSkinStats = (skinId) => {
        const skinElement = document.querySelector(`.skin-item[data-skin-id='${skinId}']`);
        const skinData = JSON.parse(skinElement.getAttribute("data-skin"));

        const content = `
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
        showModal("skin", content);
    };

    window.showWeaponStats = (weaponId) => {
        fetch(`/inventory/${weaponId}/weapon_stats`)
            .then((response) => response.json())
            .then((data) => {
                if (data.error) {
                    alert(data.error);
                    return;
                }

                const content = `
                    <p><strong>Weapon:</strong> ${data.name}</p>
                    <p><strong>Damage Multiplier:</strong> ${data.multiplier}x</p>
                `;
                showModal("weapon", content);
            })
            .catch((error) => console.error("Error fetching weapon stats:", error));
    };

    window.showConsumableStats = (consumableElement) => {
        const description = consumableElement.getAttribute("data-description");
        const name = consumableElement.querySelector(".consumable-name-display").innerText;

        const content = `
            <p><strong>Name:</strong> ${name}</p>
            <p><strong>Effect:</strong> ${description}</p>
        `;
        showModal("consumable", content);
    };

    window.closeModal = closeModal;

    // Prevent modals from showing when buttons are clicked
    document.querySelectorAll(".set-current-button, .remove-skin-button").forEach((button) => {
        button.addEventListener("click", (event) => {
            event.stopPropagation();
        });
    });

    // Close modal when clicking outside of it
    window.addEventListener("click", (event) => {
        if (Object.values(modals).includes(event.target)) {
            closeModal();
        }
    });
});
