/**
 * Created by Lenka on 28.8.2016.
 */
var socket, host;
host = "ws://localhost:3001";
//    $( document ).ready(function() {
function run_client(){
function connect() {
    try {
        socket = new WebSocket(host);

        socket.onopen = function () {
            addMessage("Socket Status: " + socket.readyState + " (open)");
        }
        socket.onclose = function () {
            addMessage("Socket Status: " + socket.readyState + " (closed)");
        }
        socket.onmessage = function (msg) {
            addMessage(msg.data);
        }
    } catch (exception) {
        addMessage("Error: " + exception);
    }
}

function addMessage(msg) {
    if (msg.charAt(0) == "*") {
        msg = msg.slice(1, msg.length);
        if (msg == "") {
            msg = "No device online."
            $("#online").text("");
        } else {
            $("#online").text("");
            var ar = msg.split(",");
            ar.forEach(function (id) {
                $("#online").append("<button>" + id + "</button>");
            })
        }
//          $("#log").text(msg);
    } else {
        $("#chat-log").append("<p>" + msg + "</p>");
    }
}

function send() {
    var text = $("#message").val();
    if (text == '') {
        addMessage("Please Enter a Message");
        return;
    }
    try {
        socket.send(text);
        addMessage("You: " + text)
    } catch (exception) {
        addMessage("Failed To Send")
    }
    $("#message").val('');
}

$(function () {
    connect();
});
//    $('#online').find("button").click(function () { TODO
//      $("#log").append("nazev zarizenia a jeho funcke")
//    });
$('#message').keypress(function (event) {
    if (event.keyCode == '13') {
        send();
    }
});
$("#disconnect").click(function () {
    socket.close()
});
$("#clear").click(function () {
    $("#chat-log").text('')
});
}