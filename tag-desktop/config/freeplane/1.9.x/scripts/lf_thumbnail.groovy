boolean overwriteExistingFile = true
def filename = '/home/djwhitt/.cache/lf/thumbnail.tmp.freeplane.' + node.map.file.name.replaceFirst('.mm$', '.jpg')
c.export(node.map, new File(filename), 'Compressed image (JPEG) (.jpg)', overwriteExistingFile)
