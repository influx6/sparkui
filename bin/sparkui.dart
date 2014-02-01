library sparkui.bin;

import 'dart:async';
import 'package:sparkui/server.dart';

void main(){

	var ui = SparkUI.create({
		'root':'../web',
	});

	ui.init().then((_){
		ui.socket.info.emit('UI Server ready!');
		ui.socket.info.emit("Server Options:\n "+ui.options.toString().split(",").join("\n").replaceAll("{","").replaceAll("}",""));
	});
	
}