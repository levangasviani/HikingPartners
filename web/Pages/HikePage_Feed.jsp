<%--
  Created by IntelliJ IDEA.
  User: Nodo
  Date: 6/19/2017
  Time: 9:46 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<div class="hike_feed ">
    <div class="post-block main-content">
        <div class="new-post">
            <div class="avatar-block post-author-avatar"
                 v-bind:style="{ backgroundImage: 'url(' + user.profilePictureAddress + ')' }"></div>
            <form action="" class="post-form" v-on:submit.prevent="sendPost">
                <div class="new-post-img" v-if="uploadingPicture">
                    <img v-bind:src="imageLink" alt="">
                    <div class="photo-remove-button" @click="cancelPicture()"><i class="fa fa-window-close"></i></div>
                </div>
                <div class="new-post-input-div">
                    <input type="text" placeholder="Write something..." class="new-post-input" autocomplete="off"
                           v-model="newPostText">
                </div>
            </form>
            <button type="button" class="upload-image-button" @click="document.querySelectorAll('.image-chooser')[0].click()"></button>
            <button type="button" class="add-video-button" @click="showLinkPopup()"></button>
        </div>
        <div class="post-popup" :class="{active : imagePopupIsActive }">
            <form v-on:submit.prevent="uploadPicture" method="post"
                  enctype="multipart/form-data" class="img-form">
                <input type="file" name="pic" accept="image/*" v-on:change="uploadPicture" class="image-chooser">
            </form>
        </div>
        <div class="post-popup" :class="{active : videoPopupIsActive}">
            <input type="text" style="margin-bottom: 10px;" v-model="youtubeLink">
            <button class="mybtn" @click="addYoutubeLink()">Add Link</button>
            <div class="close-block" @click="closeLinkPopup()">x</div>
        </div>
    </div>
    <div class="post-block main-content" v-for="(post, index) in posts">
        <div class="post-upper">
            <div class="avatar-block post-author-avatar"
                 v-bind:style="{ backgroundImage: 'url(' + post.user.profilePictureAddress + ')' }"></div>
            <div class="post-info">
                <div class="post-author-name">
                    <span>{{post.user.firstName}} </span><span>{{post.user.lastName}}</span>

                </div>
                <div class="post-time">
                    {{post.time | cutTime}}
                </div>
            </div>
        </div>

        <div class="post-text">
            <div class="post-photo" v-if="post.photo && post.photo.src != 'null' && post.photo.src != ''">
                <img v-bind:src="post.photo.src" alt="">
            </div>
            {{post.text}}
            <br>
            <iframe width="420" height="315" v-if="post.link != ''"
                    :src="post.link">
            </iframe>
        </div>
        <div class="comments-count">
            {{post.comments.length}} comment<span v-show="post.comments.length != 1">s</span>
        </div>
        <div class="comments-block">
            <div class="comments-block-inner">
                <ul class="comments-list" v-for="(comment, index) in post.comments">
                    <li class="comment">
                        <div class="avatar-block"
                             v-bind:style="{ backgroundImage: 'url(' + comment.user.profilePictureAddress + ')' }"></div>
                        <div class="comment-info">
                            <div class="comment-info__upper">
                                <div class="comment-author">
                                    <span>{{comment.user.firstName}} </span><span>{{comment.user.lastName}}</span>
                                </div>
                            </div>
                            <div class="comment-info__lower">
                                <div class="comment-time">{{comment.date | cutTime}}
                                </div>
                                <div class="like-block">
                                    <i class="fa fa-thumbs-up" v-bind:class="{ liked: comment.isLiked }"
                                       v-on:click="like(post.id, comment.commentID)" aria-hidden="true"></i>
                                    {{comment.likeNumber}}
                                </div>
                            </div>
                        </div>
                        <div class="comment-text">{{comment.comment}}
                        </div>
                    </li>
                </ul>
                <div class="comment">
                    <div class="add-comment">
                        <div class="avatar-block"
                             v-bind:style="{ backgroundImage: 'url(' + user.profilePictureAddress + ')' }">
                        </div>
                        <form action="HikePageServlet" v-on:submit.prevent="sendComment(post.id)" method="post">
                            <input v-model="commentInputs[post.id]" class="comment-input" type="text" autocomplete="off"
                                   name="add-comment"
                                   placeholder="Write a comment...">
                        </form>
                    </div>
                </div>
            </div>
        </div>


    </div>
</div>

<script>
    Vue.filter('cutTime', function (value) {
        return value.substr(0, value.length - 3);
    });

    var ws = new WebSocket("ws://localhost:8080/HikeFeedSocket/" + hikeId);
    var app = new Vue({
        el: '#vueapp',

        //These are stored instance variables for vue,
        //it will use these to bind element data and
        //modify them.
        data: {
            hikeID: hikeId,
            posts: [],
            commentInputs: {},
            newPostText: "",
            user: {},
            imagePopupIsActive: false,
            videoPopupIsActive: false,
            youtubeLink: "",
            uploadingPicture: false,
            uploadProgress: false,
            imageLink: "/Content/img/loading.gif"
        },
        //These functions will be called when page loads.
        created: function () {
            this.fetchData();
            this.user = user;
            console.log(this.user);
        },
        updated: function () {
            document.getElementsByTagName("title")[0].innerHTML = document.getElementsByTagName("setTitle")[0].innerHTML;
        },
        //These are stored methods that vue will be able to use.
        methods: {
            fetchData: function () {
                var th = this;
                axios.post("/HikePostPageServlet?hikeId=" + hikeId, {}).then(function (response) {
                    th.posts = response.data.reverse();
                });
            },

            uploadPicture: function(){
                if(this.uploadProgress){
                    return;
                }
                var self = this;
                self.uploadProgress = true;
                self.uploadingPicture = true;
                self.imageLink = "/Content/img/loading.gif";
                axios.post('/PostPhoto?hikeId=' + hikeId, new FormData(document.querySelector(".img-form"))).then(function(response){
                    if(response.status == 200){
                        self.imageLink  = response.data.imgUrl;
                    }else{
                        self.uploadingPicture = false;
                    }
                    self.uploadProgress = false;
                });
            },

            cancelPicture: function(){
                if(this.uploadProgress){
                    return;
                }
                var self = this;
                axios.post('/CancelPhoto?photoPath=' + self.imageLink, {}).then(function(response){
                    document.querySelector(".image-chooser").value = "";
                    self.imageLink = "";
                    self.uploadingPicture = false;
                });
            },

            //This method is invoked automatically when socket
            //server sends messageto this session.
            getSocketMessage: function (data) {
                console.log("----------");
                console.log(data);
                var jsonData = JSON.parse(data.data);
                console.log(jsonData);
                var action = jsonData.action;
                data = jsonData.data;
                if (action == "getComment") {
                    this.posts.find(x => x.id == data.postID).comments.push(data);
                } else if (action == "getCommentLike") {
                    if (data.liked) {
                        this.posts.find(x => x.id == data.postID).comments.find(x => x.commentID == data.commentID).likeNumber++;
                        if (data.userID == user.id) {
                            this.posts.find(x => x.id == data.postID).comments.find(x => x.commentID == data.commentID).isLiked = true;
                        }
                    } else if (this.posts.find(x => x.id == data.postID).comments.find(x => x.commentID == data.commentID).likeNumber > 0) {
                        this.posts.find(x => x.id == data.postID).comments.find(x => x.commentID == data.commentID).likeNumber--;
                        if (data.userID == user.id) {
                            this.posts.find(x => x.id == data.postID).comments.find(x => x.commentID == data.commentID).isLiked = false;
                        }
                    }
                } else if (action == "getPost") {
                    this.posts.unshift(data);
                }
            },

            //Sends new comment to socket server, called when enter is hit on comment.
            sendComment: function (postId) {
                var newCommentText = this.commentInputs[postId];
                if(newCommentText == ""){
                    return;
                }
                ws.send(JSON.stringify({
                    action: "getComment",
                    data: {
                        comment: newCommentText + "",
                        postID: postId + ""
                    }
                }));
                this.commentInputs[postId] = "";

            },

            sendPost: function () {
                if(this.uploadProgress || this.link == "" && (this.imageLink == "/Content/img/loading.gif"
                    || this.imageLink == "") && this.newPostText == ""){
                    return;
                }
                ws.send(JSON.stringify({
                    action: "getPost",
                    data: {
                        post: this.newPostText + "",
                        link: this.youtubeLink,
                        photoPath: this.imageLink == "/Content/img/loading.gif" || this.imageLink == "" ? "null" : this.imageLink
                    }
                }));
                this.newPostText = "";
                this.youtubeLink = "";
                this.imageLink = "";
                this.uploadingPicture = false;
            },


            //This function is called when like button is clicked.
            like: function (postID, commentID) {
                ws.send(JSON.stringify({
                    action: "getCommentLike",
                    data: {
                        postID: "" + postID,
                        commentID: "" + commentID,
                    }
                }));
            },

            showLinkPopup: function () {
                this.videoPopupIsActive = true;
            },

            addYoutubeLink: function () {
                this.videoPopupIsActive = false;
            },

            closeLinkPopup: function () {
                this.videoPopupIsActive = false;
            },

            showImagePopup: function () {
                this.imagePopupIsActive = true;
            },

            closeImagePopup: function () {
                this.imagePopupIsActive = false;
            }

        }
    });
    ws.onmessage = app.getSocketMessage;
</script>
