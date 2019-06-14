#include "version.h"
#include "App.h"

#include <iostream>

int main(int argc, char* argv[]) {
    std::cout << "# inuxcore" << std::endl;
    std::cout << "## version: " << inuxcore_VERSION_MAJOR << "." << inuxcore_VERSION_MINOR << std::endl;

    /* ws->getUserData returns one of these */
    struct PerSocketData {

    };

    /* Very simple WebSocket echo server */
    uWS::App().ws<PerSocketData>("/*", {
        /* Settings */
        .compression = uWS::SHARED_COMPRESSOR,
        .maxPayloadLength = 16 * 1024,
        /* Handlers */
        .open = [](auto *ws, auto *req) {

        },
        .message = [](auto *ws, std::string_view message, uWS::OpCode opCode) {
            ws->send(message, opCode);
        },
        .drain = [](auto *ws) {
            /* Check getBufferedAmount here */
        },
        .ping = [](auto *ws) {

        },
        .pong = [](auto *ws) {

        },
        .close = [](auto *ws, int code, std::string_view message) {

        }
    }).listen("0.0.0.0", 61992, [](auto *token) {
        if (token) {
            std::cout << "Listening on port " << 61992 << std::endl;
        }
    }).run();
}