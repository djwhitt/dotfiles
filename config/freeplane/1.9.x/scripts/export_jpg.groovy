boolean overwriteExistingFile = true
def filename = '/tmp/' + node.map.file.name.replaceFirst('.mm$', '.jpg')
c.export(node.map, new File(filename), 'Compressed image (JPEG) (.jpg)', overwriteExistingFile)
