package WebSockets;

/**
 * Created by Sandro on 17.06.2017.
 */
import Models.Comment;
import Models.MiniUser;
import Models.Post;
import com.google.gson.Gson;
import com.google.gson.JsonElement;

import javax.websocket.*;
import javax.websocket.server.*;
import java.io.*;
import java.util.*;

@ServerEndpoint("/HikeCommentsSocket/{hikeId}")
public class HikeCommentsWebSocketServer {
    private static Map<Integer, Map<String, Session>> connectedSessions = new HashMap<>();
    private static WebSocketHelper webSocketHelper = new WebSocketHelper();

    @OnOpen
    public void open(Session session, @PathParam("hikeId") int hikeId) {
        if(!connectedSessions.containsKey(hikeId)){
            connectedSessions.put(hikeId, new HashMap<>());
        }
        connectedSessions.get(hikeId).put(session.getId(), session);
    }

    @OnClose
    public void close(Session session, @PathParam("hikeId") int hikeId) {connectedSessions.get(hikeId).remove(session.getId());}

    @OnError
    public void onError(Throwable error) {}

    @OnMessage
    public void handleMessage(String message, Session session, @PathParam("hikeId") int hikeId) {
        //JsonObject jsonMessage = reader.readObject();
        Gson gson = new Gson();

        Map<String, Object> jsonMessage = gson.fromJson(message, Map.class);
        if ("getComment".equals(jsonMessage.get("action"))) {
            //bazashi komentaris chagdeba
            webSocketHelper.sendToAllConnectedSessions(jsonMessage, hikeId, connectedSessions.get(hikeId));
        }

        if ("getCommentLike".equals(jsonMessage.get("action"))) {
            //avsaxot bazashi like;
            //am likeze informaciis gagzavna yvela am hikeze miertebul sesiastan
        }
    }
}