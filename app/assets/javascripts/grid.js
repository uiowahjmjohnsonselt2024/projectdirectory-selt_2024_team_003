document.addEventListener('DOMContentLoaded', () => {
    const gridSquares = document.querySelectorAll('.grid-square');
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

    gridSquares.forEach(square => {
        square.addEventListener('click', () => {
            const x = parseInt(square.dataset.x, 10);
            const y = parseInt(square.dataset.y, 10);

            fetch('/pages/move', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': csrfToken,
                },
                body: JSON.stringify({ x_position: x, y_position: y }),
            })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        updateGridAndProfile(data.position);
                    } else {
                        alert(data.errors.join(', '));
                    }
                });
        });
    });

    function updateGridAndProfile(position) {
        document.querySelector('.current-position').textContent = `Current Position: (${position.x}, ${position.y})`;

        // Highlight new current square
        document.querySelectorAll('.grid-square').forEach(square => {
            square.classList.remove('current-square');
        });
        const newSquare = document.querySelector(`[data-x="${position.x}"][data-y="${position.y}"]`);
        newSquare.classList.add('current-square');
    }
});
