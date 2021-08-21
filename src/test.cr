macro test(op)
	{{op.args[0].id}} += 1
	{{op.receiver.id}}
	{{op.name}}
	{{debug}}
end

a = 1
b = 2
tp = test(a + b)

puts tp
