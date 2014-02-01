part of sparkui;

class SparkUITree{
	MapDecorator options;

	SparkUITree([Map op]){
		this.options = new MapDecorator.from(Hub.merge({
			'root': '../web',
			'noflo': '../web/noflo/index.html',
			'uiFile': '../web/index.html',
			'assets': '../web/assets',
			'addr':'127.0.0.1',
			'socketAddr':'ws://127.0.0.1:3000/ws',
			'port': 3000
		},Hub.switchUnless(op,{})));
		
	// this.options.update("root", Platform.script.resolve(this.options.get('root')).toFilePath());
	//    this.options.update("noflo_dir", Platform.script.resolve(this.options.get('noflo_dir')).toFilePath());
	//    this.options.update("assets", Platform.script.resolve(this.options.get('assets')).toFilePath());

	}

}

