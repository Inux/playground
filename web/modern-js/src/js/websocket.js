let dateOld = Date.now();

function run() {
    const ws = new WebSocket("ws://127.0.0.1:61992");

    ws.onopen = (event) => {
        console.log('connected');
        ws.send(Date.now());
    };

    ws.onclose = () => {
        console.log('disconnected');
    };

    ws.onmessage = () => {
        console.log(`Roundtrip time: ${Date.now() - dateOld} ms`);

        setTimeout(function timeout() {
            dateOld = Date.now();
            ws.send(dateOld);
        }, 500);
    };
}

export default {
    run
}

