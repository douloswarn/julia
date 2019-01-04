# This file is a part of Julia. License is MIT: https://julialang.org/license

mutable struct InvasiveLinkedList{T}
    # Invasive list requires that T have a field `.next >: U{T, Nothing}` and `.owner >: ILL{T}`
    head::Union{T, Nothing}
    tail::Union{T, Nothing}
    InvasiveLinkedList{T}() where {T} = new{T}(nothing, nothing)
end

#const list_append!! = append!
#const list_delete! = delete!

iterate(q::InvasiveLinkedList) = (h = q.head; h === nothing ? h : (h, h))
iterate(q::InvasiveLinkedList{T}, v::T) where {T} = (h = v.next; h === nothing ? h : (h, h))

isempty(q::InvasiveLinkedList) = (q.head === nothing)

function length(q::InvasiveLinkedList)
    i = 0
    head = q.head
    while head !== nothing
        i += 1
        head = head.next
    end
    return i
end

function list_append!!(q::InvasiveLinkedList{T}, q2::InvasiveLinkedList{T}) where T
    q === q2 && error("can't append list to itself")
    head2 = q2.head
    if head2 !== nothing
        tail2 = q2.tail::Task
        q2.head = nothing
        q2.tail = nothing
        tail = q.tail
        q.tail = tail2
        if tail === nothing
            q.head = head2
        else
            tail.next = head2
        end
        while head2 !== nothing
            head2.queue = q
            head2 = head2.next
        end
    end
    return q
end

function push!(q::InvasiveLinkedList{T}, val::T) where T
    val.queue === nothing || error("val already in a list")
    val.queue = q
    tail = q.tail
    if tail === nothing
        q.head = q.tail = val
    else
        tail.next = val
        q.tail = val
    end
    return q
end

function pushfirst!(q::InvasiveLinkedList{T}, val::T) where T
    val.queue === nothing || error("val already in a list")
    val.queue = q
    head = q.head
    if head === nothing
        q.head = q.tail = val
    else
        val.next = head
        q.head = val
    end
    return q
end

function popfirst!(q::InvasiveLinkedList)
    val = q.head::Task
    list_delete!(q, val) # cheap
    return val
end

function pop!(q::InvasiveLinkedList)
    val = q.tail::Task
    list_delete!(q, val) # expensive!
    return val
end

function list_delete!(q::InvasiveLinkedList{T}, val::T) where T
    val.queue === q || return
    head = q.head::Task
    if head === val
        if q.tail::Task === val
            q.head = q.tail = nothing
        else
            q.head = val.next::Task
        end
    else
        head_next = head.next
        while head_next !== val
            head = head_next
            head_next = head.next
        end
        if q.tail::Task === val
            head.next = nothing
            q.tail = head
        else
            head.next = val.next::Task
        end
    end
    val.next = nothing
    val.queue = nothing
    return q
end

function list_delete!(q::Array{T}, val::T) where T
    i = findfirst(equalto(val), q)
    i === nothing || deleteat!(q, i)
    return q
end
