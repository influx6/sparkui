library sparkflow_ui;

import 'dart:html';
import 'dart:async';
import 'package:hub/hub.dart';
import 'package:sparkflow/sparkflow.dart';
import 'package:socketire/socketire.dart';
import 'package:streamable/streamable.dart';
import 'package:streamable/runtime/runtimes.dart';

final defaults = {
	'root': '../web',
	'noflo_dir': '../web/noflo',
	'runtime': 'postmessage',
	'type': 'server' //client
};

class SparkUI{
	MapDecorator options;

	static create([op]) => new SparkUI(op);

	SparkUI([Map op]){
		this.options = new MapDecorator.from(Hub.switchUnless(op,defaults));
	}

	void bootUI(){

	}

}