#################################################################################
#
#   Factor.jl : Factorization
#
#################################################################################

################################################################################
#
#   Type
#
################################################################################

@doc raw"""
    Fac{T <: RingElement}

Type for factored ring elements. The structure holds a unit of type `T` and is
an iterable collection of `T => Int` pairs for the factors and exponents.
"""
mutable struct Fac{T <: RingElement}
   unit::T
   fac::Dict{T, Int}

   function Fac{T}() where {T}
     f = new()
     f.fac = Dict{T, Int}()
     return f
   end
end

function Fac(u::T, d::Dict{T, Int}) where {T}
   f = Fac{T}()
   f.unit = u
   f.fac = d
   return f
end

@doc raw"""
    unit(a::Fac{T}) -> T

Return the unit of the factorization.
"""
unit(a::Fac) = a.unit

#primes(a::Fac) = collect(keys(a.fac))

@doc raw"""
    evaluate(a::Fac{T}) -> T

Multiply out the factorization into a single element.
"""
function evaluate(a::Fac)
   r = a.unit
   for (p, e) in a
      r *= p^e
   end
   return r
end

################################################################################
#
#   Syntax sugar
#
################################################################################

@doc raw"""
    in(a, b::Fac)

Test whether $a$ is a factor of $b$.
"""
function Base.in(a, b::Fac{T}) where {T}
   # convert is necessary when T == ZZRingElem, because hash on ZZRingElem
   # doesn't coincide with hash on Integer
   convert(T, a) in keys(b.fac)
end

@doc raw"""
    getindex(a::Fac, b) -> Int

If $b$ is a factor of $a$, the corresponding exponent is returned. Otherwise
an error is thrown.
"""
function getindex(a::Fac{T}, b) where {T}
  b = convert(T, b)
  if haskey(a.fac, b)
    return a.fac[b]
  else
    error("$b is not a factor of $a")
  end
end

@doc raw"""
    setindex!(a::Fac{T}, c::Int, b::T)

If $b$ is a factor of $a$, the corresponding entry is set to $c$.
"""
function setindex!(a::Fac{T}, c::Int, b::T) where {T}
  if haskey(a.fac, b)
    error("$b is already set (to $(a[b]))")
  else
    setindex!(a.fac, c, b)
  end
end


################################################################################
#
#   String I/O
#
################################################################################

function expressify(@nospecialize(a::Fac); context = nothing)
   prod = Expr(:call, :cdot)
   if isdefined(a, :unit)
      push!(prod.args, expressify(a.unit, context = context))
   else
      push!(prod.args, Expr(:call, :*, "[unit not set]"))
   end
   for (p, i) in a.fac
      ep = expressify(p, context = context)
      if isone(i)
         push!(prod.args, ep)
      else
         push!(prod.args, Expr(:call, :^, ep, i))
      end
   end
   return prod
end

@enable_all_show_via_expressify Fac

################################################################################
#
#   Make Factor objects iterable
#
################################################################################

Base.iterate(a::Fac) = Base.iterate(a.fac)

Base.iterate(a::Fac, b) = Base.iterate(a.fac, b)

Base.eltype(::Type{Fac{T}}) where {T} = Base.eltype(Dict{T, Int})

@doc raw"""
    length(a::Fac) -> Int

Return the number of factors of $a$, not including the unit.
"""
Base.length(a::Fac) = Base.length(a.fac)
