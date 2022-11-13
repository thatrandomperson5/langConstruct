import formatstr
import std/xmltree
import std/strtabs

type NodeType = ref object
    name: string
    fmt: string

type ConstructNode = ref object
    nodetype: NodeType
    value: StringTableRef
    children: seq[ConstructNode]

proc createNode*(nodetype: NodeType, value: varargs[tuple[key,
        val: string]]): ConstructNode =
    return ConstructNode(
                         nodetype: nodetype,
                         value: value.newStringTable,
                         children: @[]
        )
proc `++`*(nodetype: NodeType, value: varargs[tuple[key, val: string]]): ConstructNode =
    return createNode(nodetype, value)


proc toXml*(node: ConstructNode): XmlNode =
    var output = newElement(node.nodetype.name)
    let thisnode = node
    if thisnode.value.haskey("text"):
        output.add newText(thisnode.value["text"])
        thisnode.value.del("text")
    output.attrs = thisnode.value
    if thisnode.children.len > 0:
        for child in thisnode.children:
            output.add toXml(child)
    return output
proc `$`*(node: ConstructNode): string =
    let xml = toXml(node)
    return $xml
proc add*(node, othernode: ConstructNode) =
    node.children.add othernode
proc `[]`*(node: var ConstructNode, index: int): var ConstructNode =
    return node.children[index]

proc `[]`*(node: ConstructNode, index: int): ConstructNode =
    return node.children[index]
proc child*(node: ConstructNode, name: string): ConstructNode =
    echo node.children
    for child in node.children:
        if child.nodetype.name == name:
            return child
proc clear*(node: ConstructNode) =
    if node.children.len > 0:
        for i in 0 .. (node.children.len - 1):
            node.children.del(i)





proc construct*(node: ConstructNode): string = 
    var children: seq[string] = @[]
    if node.children.len > 0:
        for child in node.children:
            children.add(child.construct)
    return node.nodetype.fmt.format(node.value, children)
