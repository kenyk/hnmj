log = {}

--执行
function log.print(...)
    print("----------------------------------------------------------------------------------")
	print(" ")
    print(...)
    print(" ")
    print("----------------------------------------------------------------------------------")
end


function log.dump(data, max_level, prefix)
    print("----------------------------------------------------------------------------------")
	print(" ")
    dump(data, max_level, prefix)
    print(" ")
    print("----------------------------------------------------------------------------------")
end
