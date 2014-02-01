import 'dart:html';
import 'dart:async';
import 'package:sparkflow/sparkflow.dart';
import 'package:sparkui/client.dart';


void main() {

	var ui = SparkUI.create(window,{
		'frameId':'nofloFrame',
		'parentId':'noflo'
	});

	ui.usePostMessage();

}

