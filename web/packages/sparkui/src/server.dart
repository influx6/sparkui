library sparkui;

import 'dart:io';
import 'dart:async';
import 'package:hub/hub.dart';
import 'package:sparkflow/sparkflow.dart';
import 'package:socketire/server.dart';
import 'package:streamable/streamable.dart';
import 'package:path/path.dart' as paths;


part 'tree.dart';



class SparkUI extends SparkUITree{
	SocketireServer socket;
	Completer ready;

	static create([op]) => new SparkUI(op);

	SparkUI([Map op]): super(op){
		this.options.add('type','server');
	}

	void _setUp(){

			this.ready = new Completer();
			this.socket = SocketireServer.create(this.options.get('addr'),this.options.get('port'));
			this.socket.initGuardedFS(this.options.get('root'));
			this.socket.request('/',new RegExp(r'^/$'));
			this.socket.requestFile('ui',new RegExp(r'^/ui'),this.options.get('uiFile'));
			this.socket.requestFS('web',new RegExp(r'/web'),this.options.get('root'));
			this.socket.request('ws',new RegExp(r'^/ws'));

			this.socket.initd.on((n){

				n.info.on((w){
					print('#log::(#request) $w');				
				});

				n.stream('/').on((g){
					n.render('web',g);
				});

				n.stream('ui').on(StaticRequestHelpers.renderFileRequest((r,d){
					r.httpSend(d);
				}));

				var web = n.applyFSTransformer('web',(r){
					return r.request.uri.path.replaceAll('/web','.');
				},(e){
					return '/'+e;
				});

				web.on((r){

					if(!r.options.get('isRootDirectory')) return null;

					return r.spec.listDirectory().then((_){
						if(_ is Exception) return r.httpSend('Resource Not Found (404)!');

						r.headers('Content-Type','text/html');
						var data = new List.from(['<ul>']);
						r.options.get('handler')(r,_).then((list){
							var render = new List();
							list.forEach((n){  data.add('<li><a href="$n">$n</a></li>'); });
							data.add('</ul>');

							n.fs.File('directory.html').readAsString().then((o){
								r.httpSend(o.replaceAll("{{directorylists}}",data.join('')));
							},onError:(e){
								return r.httpSend('Resource Not Found (404)!');
							});
						});

					});
				
				});

				web.on((r){

					if(!r.options.get('valid') || r.options.get('isRootDirectory')) return;

						r.spec.get(r.options.get('realPath'),(dir){
							dir.then((_){

								r.headers('Content-Type','text/html');
								var data = new List.from(['<ul>']);
								r.options.get('handler')(r,_).then((list){
									var render = new List();
									data.add('<li><a href="/">root</a></li>'); 
									data.add('<li><a href="..">back</a></li>'); 
									list.forEach((n){  data.add('<li><a href="$n">$n</a></li>'); });
									data.add('</ul>');

									n.fs.File('directory.html').readAsString().then((o){
										var render = o.replaceAll("{{directorylists}}",data.join(''));
										r.httpSend(render);
									},onError:(e){
										return r.httpSend('Resource Not Found (404)!');
									});
								});
								
							});
						},(file){
							file.then((data){
								r.httpSend(data);
							});

						},(e){
							return r.httpSend('Resource Not Found (404)!');
						});

				});

			});

			this.socket.ready().then((f){
				this.ready.complete(this);
			});


	}

	dynamic init(){

		runZoned((){

			this._setUp();

		},onError:(e,s){
			this.socket.errors.emit(e);
			this.init();

		});

		return this.ready.future;
	}

}

