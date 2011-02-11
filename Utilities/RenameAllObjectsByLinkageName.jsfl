function renameAll(a) {
	var namePath;
	for (var i = 0; i < a.length; i++) {
		if (a[i] instanceof SymbolInstance) {
			namePath = a[i].libraryItem.name.split('/');
			a[i].name = namePath[namePath.length-1];
			fl.trace(a[i].name);
		} else if (a[i] instanceof Shape) {
			renameAll(a[i].members);
		} else {
			fl.trace(a[i]);
		}
	}
}
renameAll(fl.getDocumentDOM().selection);
