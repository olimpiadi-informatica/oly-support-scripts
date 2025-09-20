'use strict';

export function main(round_robin_delay_ms) {

    const threshold_ms = 2 * 60 * 1000;

    function update_timestamp(preview) {
        const updated_text = preview.querySelector('.last-updated');
        const last_update = parseInt(updated_text.getAttribute('tag-timestamp')) * 1000;
        updated_text.textContent = new Date(last_update).toLocaleTimeString();

        if(last_update < Date.now() - threshold_ms) {
            preview.classList.add('old-timestamp');
        }
        else {
            preview.classList.remove('old-timestamp');
        }
    }

    const previews = document.querySelectorAll('.preview');

    let current_idx = 0;
    function update_one() {
        const preview = previews[current_idx];
        const ip = preview.getAttribute('tag-ip');
        const image = preview.querySelector('.preview-image');
        const updated_text = preview.querySelector('.last-updated');

        image.src = image.src.split('?')[0] + '?' + Date.now();

        fetch('timestamp/' + ip)
            .then(response => response.text())
            .then(data => {
                updated_text.setAttribute('tag-timestamp', data);
                update_timestamp(preview);
                setTimeout(update_one, round_robin_delay_ms);
            });

        current_idx = (current_idx + 1) % previews.length;
    }
    update_one();

    function update_timestamps() {
        for(const preview of previews) {
            update_timestamp(preview);
        }
    }
    update_timestamps();
    setInterval(update_timestamps, 1000);
}
