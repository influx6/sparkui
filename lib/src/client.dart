library sparkui;

import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'package:hub/hubclient.dart';
import 'package:sparkflow/sparkflow.dart';
import 'package:socketire/client.dart';
import 'package:streamable/streamable.dart';

part 'tree.dart';

class PostMessageRuntime extends MessageRuntime{
	Window contextWindow;
	IFrameElement frame;

	static create(m,[f]) => new PostMessageRuntime(m,f);

	PostMessageRuntime(JStripe m,[bool ce]): super(m,ce){
		this.frame = this.root.core;
		this.contextWindow = this.root.core.contentWindow;

		this.root.fragment('contentWindow');
		this.root.methodFragment('contentWindow','addEvent','addEventListener');
		this.init();
	}

	void bindOutStream(){
		this.outMessages.on((message){
			this.contextWindow.parent.postMessage(message['data'],message['target'].href,message['ports']);
		});
	}

	void bindInStream(){
		this.root.runOn('contentWindow','addEvent')(['message',(e){
			var message = e['data'];

			if(message['protocol'] == null && message['command'] == null) return;

			this.inMessages.emit({'event': e, 'data': JSON.decode(this.root.toDartJSON(message))});
		},false]);
	}

	void bindErrorStream(){
		this.root.runOn('contentWindow','addEvent')(['error',(e){
			this.send('network','error',{ 'payload': e });
		},false]);
	}

}

class SocketMessageRuntime extends MessageRuntime{
	
	static create(m,[ce]) => new SocketMessageRuntime(m,ce);

	SocketMessageRuntime(SocketireClient m,[ce]): super(m,ce);

	void bindOutStream(){
		this.outMessages.on((message){

		});
	}

	void bindInStream(){
    
	}

	void bindErrorStream(){
		this.root.addEventListener('error',(e){
			this.send('network','error',{ 'payload': e.toString() });
		});
	}
}


class SparkUI extends SparkUITree{
	final _alive = Switch.create();
	Element rootWindow,rootDocument,frame,parent;
	SocketireClient socket;
	PostMessageRuntime pm;
	SocketMessageRuntime sm;
	Completer ready;
	JStripe strip;

	static create(w,[op]) => new SparkUI(w,op);

	SparkUI(Window w,[Map op]): super(op){
		this.options.add('type','client');
		this.options.add('frameId','clientFrame');
		this.options.add('parentId','clientParent');

		this.rootWindow = w;
		this.rootDocument = this.rootWindow.document;
		this.parent = this.rootDocument.querySelector('#'+this.options.get('parentId'));
		this.createFrame();
	}

	void createFrame(){
		this.frame = new IFrameElement();
		this.frame.setAttribute('id',this.options.get('frameId'));
		this.frame.setAttribute('style',"width: 100%; height: 100%");
		this.frame.setAttribute('src',this.options.get('noflo'));
		this.frame.setAttribute('name','nofloFrame');
		this.parent.append(this.frame);
		this.strip = JStripe.create(this.frame);
	}

	dynamic useWebSocket(){
		if(this._alive.on()) return;

		this._alive.switchOn();
		this.options.add('method','websocket-runtime');

		this.socket = SocketireClient.create(this.options.get('socketAddr'));
		this.sm = SocketMessageRuntime.create(this.socket,true);
	}

	dynamic usePostMessage(){
		if(this._alive.on()) return;
		
		this._alive.switchOn();
		this.options.add('method','postmessage-runtime');

		this.pm = PostMessageRuntime.create(this.strip,true);

		this.pm.inMessages.on((e){
			print("inMessage# ${e['data']}"); 

		});

		// this.pm.outMessages.on((e){ print("outMessage# $e"); });
		// this.pm.errMessages.on((e){ print("errMessage# $e"); });
	}

	String toString(){
		var buffer = new StringBuffer();
		buffer.write('#window: ${this.rootWindow}');
		buffer.write('\n');
		buffer.write('#document: ${this.rootDocument}');
		buffer.write('\n');
		buffer.write('#parent: ${this.parent}');
		buffer.write('\n');
		buffer.write('#frame: ${this.options.get("frameId")}');
		buffer.write('\n');
		buffer.write('#options: \n ${this.options.toString().split(",").join("\n").replaceAll("{","").replaceAll("}","")}');
		return buffer.toString();
	}
}

