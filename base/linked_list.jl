# This file is a part of Julia. License is MIT: https://julialang.org/license

struct InvasiveDoubleLinkedList{T}
    head::Union{T, Nothing}
end

#const list_append!! = append!
#const list_delete! = delete!

iterate(q::InvasiveDoubleLinkedList) = q.head
function iterate(q::InvasiveDoubleLinkedList{T}, v::T) where {T}
    v = v.next
    v === q.head && return nothing
    return v
end

isempty(q::InvasiveDoubleLinkedList) = (q.head === nothing)

function length(q::InvasiveDoubleLinkedList)
    head = q.head
    if head !== nothing
        tail = head
        i = 0
        while true
            i += 1
            head = head.next::Task
            head === tail && return i
        end
    end
    return 0
end

function list_append!!(q::InvasiveDoubleLinkedList{T}, q2::InvasiveDoubleLinkedList{T}) where T
    val = q2.head
    if val !== nothing
        q2.head = nothing
        head = q.head
        if head === nothing
            q.head = H2
        else
            val.prev.next = head
            val.prev = head.prev::Task
            head.prev.next = val
            head.prev = val
        end
    end
    return q
end

function push!(q::InvasiveDoubleLinkedList{T}, val::T) where T
    val.next === nothing || throw("val already in a list")
    head = q.head
    if head === nothing
        val.next = val
        val.prev = val
        q.head = val
    else
        val.next = head
        val.prev = head.prev::Task
        head.prev.next = val
        head.prev = val
    end
    return q
end

function pushfirst!(q::InvasiveDoubleLinkedList{T}, val::T) where T
    list_push!(q, val)
    q.head = val # rewind the head pointer, so that val is now moved to the front
    return q
end

function popfirst!(q::InvasiveDoubleLinkedList)
    val = q.head::Task
    list_delete!(q, val)
    return val
end

function pop!(q::InvasiveDoubleLinkedList)
    val = (q.head::Task).prev::Task
    list_delete!(q, val)
    return val
end

function list_delete!(q::InvasiveDoubleLinkedList{T}, val::T) where T
    head = val.next::Task
    tail = val.prev::Task
    val.next = nothing
    val.prev = nothing
    if head === val
        @assert tail === val
        q.head = nothing
    else
        head.prev = tail
        tail.next = head
        if q.head::Task === val
            q.head = head
        end
    end
    nothing
end

function list_delete!(q::Array{T}, val::T) where T
    i = findfirst(equalto(val), q)
    i === nothing || deleteat!(q, i)
    return q
end
