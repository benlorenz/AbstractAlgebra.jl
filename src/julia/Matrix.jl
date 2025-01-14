###############################################################################
#
#   Matrix.jl : Additional AbstractAlgebra functionality for Julia Matrices
#
###############################################################################

nrows(A::Matrix{T}) where {T} = size(A)[1]
ncols(A::Matrix{T}) where {T} = size(A)[2]

function is_zero_row(M::Matrix, i::Int)
    for j = 1:ncols(M)
        if !iszero(M[i, j])
            return false
        end
    end
    return true
end

# TODO: add `is_zero_column(M::Matrix{T}, i::Int) where {T<:Integer}` and specialized functions in Nemo

zero_matrix(::Type{Int}, r, c) = zeros(Int, r, c)

###############################################################################
#
#   Conversion from MatrixElem
#
###############################################################################

"""
    Matrix(A::MatrixElem{T}) where T <: NCRingElement

Convert `A` to a Julia `Matrix` of the same dimensions with the same elements.

# Examples
```jldoctest; setup = :(using AbstractAlgebra)
julia> A = ZZ[1 2 3; 4 5 6]
[1   2   3]
[4   5   6]

julia> Matrix(A)
2×3 Matrix{BigInt}:
 1  2  3
 4  5  6
```
"""
Matrix(M::MatrixElem{T}) where {T<:NCRingElement} = eltype(M)[M[i, j] for i = 1:nrows(M), j = 1:ncols(M)]

"""
    Array(A::MatrixElem{T}) where T <: NCRingElement

Convert `A` to a Julia `Matrix` of the same dimensions with the same elements.

# Examples
```jldoctest; setup = :(using AbstractAlgebra)
julia> R, x = ZZ["x"]; A = R[x^0 x^1; x^2 x^3]
[  1     x]
[x^2   x^3]

julia> Array(A)
2×2 Matrix{AbstractAlgebra.Generic.Poly{BigInt}}:
 1    x
 x^2  x^3
```
"""
Array(M::MatrixElem{T}) where {T<:NCRingElement} = Matrix(M)
