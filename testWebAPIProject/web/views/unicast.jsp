<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Unicast</title>
<script src="<%=request.getContextPath()%>/resources/js/jquery-3.3.1.min.js"></script>

<style>
 #messageWindow {
    background:LightSkyBlue;
    height:300px;
    overflow:auto;송대섭
 }
 .chat_content{
    background:  rgb(255, 255, 102);
    padding: 10px;
    border-radius: 10px;
    display: inline-block;
    position: relative;
    margin: 10px;
    float: right;
    clear: both;
 }
 
 .chat_content:after{
    content: '';
   position: absolute;
   right: 0;
   top: 50%;
   width: 0;
   height: 0;
   border: 20px solid transparent;
   border-left-color:  rgb(255, 255, 102);
   border-right: 0;
   border-top: 0;
   margin-top: -3.5px;
   margin-right: -10px;
 }
 
 .other-side {
    background: white;
    float:left;
    clear:both;
 }
 
 .other-side:after{
    content: '';
   position: absolute;
   left: 0;
   top: 50%;
   width: 0;
   height: 0;
   border: 20px solid transparent;
   border-right-color: white;
   border-left: 0;
   border-top: 0;
   margin-top: -3.5px;
   margin-left: -10px;
 }
</style>

</head>
<body>
	<h1>Unicast란?</h1><br>
	<h3>각 사용자가 1:1로 통신하는 방식</h3><br>
	<p>Ex) 1:1 카톡, 전화 통화, 문자메세지</p>
	사용할 ID : <input type="text"  id="chat_id" size="10" /><br> 
	상대방 ID : <input type="text" id="recvUser" size="10" />&nbsp;
	<button type="button" id="startBtn">채팅하기</button>
	
	<!-- 채팅 창 구현 부분 -->
	<div style="display:none;" id="chatbox"><br>
		<fieldset>
			<div id="messageWindow"></div><br>
			<input type="text" id="inputMessage" onkeyup="enterKey()"/>
			<input type="submit" value="보내기" onclick="send()"/>
			<button type="button" id="endBtn">나가기</button>
		</fieldset>
	</div>
	
	<script>
		
		// 1. 스타트 버튼을 눌렀을 때 채팅 영역 활성화 및 스타트 버튼 소멸 구문
		$('#startBtn').on('click',function(){
			$('#chatbox').css('display','block');
			$(this).css('display','none');
			connection();
		});
		
		// 2. 나가기 버튼을 눌렀을 때 채팅 영역 비활성화 및 스타트 버튼 재생성 구문
		$('#endBtn').on('click',function(){
			$('#chatbox').css('display','none');
			$('#startBtn').css('display','inline');
			webSocket.send($('#char_id').val()+"|님이 채팅방을 퇴장하였습니다.");
			webSocket.Close();
		});
		
		
		// 3. 상대방과 연결을 위한 웹 소켓 객체 생성
			
			// 3-1. 채팅 창의 내용 부분
			var $textarea = $('#messageWindow');
			
			// 3-2. 채팅 서버		
			var webSocket = null;
			
			// 3-3. 내가 보낼 문자열을 담은 input 태그          
			var $inputMessage = $('#inputMessage');
		
			function connection(){  // (W)eb(S)ocket://
				webSocket = new WebSocket('ws://localhost:8088'+'<%=request.getContextPath()%>/unicast');
			
				// 웹 소켓을 통해 연결이 이루어 질 때 동작할 메소드
				webSocket.onopen = function(event){
				
					$textarea.html("<p class='chat_content'>"+$('#chat_id').val() +"님이 입장하셨습니다.</p><br>");
					
					// 웹 소켓을 통해 만든 채팅 서버에 참여한 내용을 메세지로 전달 
					// 내가 보낼 때에는 send / 서버로부터 받을 때에는 message
					
					webSocket.send($('#chat_id').val()+"|님이 입장하였습니다.");
				}

				// 서버로부터 메세지를 전달 받을 때 동작하는 메소드
				webSocket.onmessage = function(event){
					// 동작할 부분
					onMessage(event);
				}
				
				// 서버에서 에러가 발생할 경우 동작할 메소드 
				webSocket.onerror = function(event){
					onError(event);
				}
				// 서버와의 연결이 종료될 경우 동작하는 메소드 
				webSocket.onclose =function(event){
					//onClose(event);
				}
				
				// 엔터키를 누를 경우 메세지 보내기
			
				
			};
			
			function enterKey(){
				if(window.event.keyCode == 13)
					send();
			}
			
			
			//--------------------------------------생성한 메소드 작성 부분
				// 서버로 메세지를 전달하는 메소드
				function send(){
					if($inputMessage.val() == ""){
						// 메세지를 입력하지 않을 경우
						alert("메세지를 입력해 주세요!");
						// 메세지가 입력 되었을 경우
					}else{
						$textarea.html(
								$textarea.html()+"<p class='chat_content'>나 :"+$inputMessage.val()+"</p><br>");
						
						webSocket.send($('#chat_id').val()+"|"+$inputMessage.val());
						
						$inputMessage.val("");
					}
					$textarea.scrollTop($textarea.height());
				}
				// 서버로부터 메세지를 (받을 때!!!!)수행할 메소드
				function onMessage(event){
					var message = event.data.split("|");
					
					// 보낸 사람의 ID
					var sender = message[0];
					
					// 전달한 내용
					var content = message[1];
					
					if(content == "" || !sender.match($('#recvUser').val())){
						
						//전달 받은 글이 없거나, 전달한 사람이 내가 연결하려는 상대방이 아닐경우 아무 내용도 실행하지 않겠다.
					}else{
						$textarea.html(
								$textarea.html()+"<p class='chat_content other-side'>"+sender+" : "+content+"</p><br>");
						
						$textarea.scrollTop($textarea.height());
					}
				}
				
				function onError(event){
					alert(event.data);
				}
				
				function onClose(event){
					alert(event);
				}
		
		/*
			웹 소켓 생성 후 동작 하는 웹 소켓 메소드들
			
			1. open : 웹 소켓 객체 생성 시 동작하여 서버와 연결을 해주는 메소드
			
			2. send : 서버에 특정 데이터를 전달하는 메소드
			
			3. message : 서버에서 전달하는 데이터를 받을 메소드
			
			4. error : 서버에서 데이터를 전달하는 도중 에러가 발생할 경우 수행되는 메소드
			
			5. close : 사용자가 서버와의 연결을 끊을 경우 사용하는 메소드
			
			※ 웹 소켓 객체는 생성자를 통해서 선언 시 서버와의 연결을 자동으로 실행한다.※
			(open 메소드가 자동으로 실행한다.)
		
		*/
		
		
	</script>
	
</body>
</html>