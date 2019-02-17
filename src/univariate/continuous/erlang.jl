"""
    Erlang <: ContinuousUnivariateDistribution

# Constructors

    Erlang(α|alpha|shape=1, θ|theta|scale=1)

Construct an `Erlang` distribution object with shape `α` amd scale `θ`.

# Details

The *Erlang distribution* is a special case of a [`Gamma`](@ref) distribution with integer shape parameter.

```julia
Erlang()
Erlang(α=3)
Erlang(α=3, θ=5)
```

# External links

* [Erlang distribution on Wikipedia](http://en.wikipedia.org/wiki/Erlang_distribution)

"""
struct Erlang{T<:Real} <: ContinuousUnivariateDistribution
    α::Int
    θ::T

    function Erlang{T}(α::Real, θ::T) where T
        @check_args(Erlang, isinteger(α) && α >= zero(α))
        new{T}(α, θ)
    end
end

Erlang(α::Int, θ::T) where {T<:Real} = Erlang{T}(α, θ)
Erlang(α::Int, θ::Integer) = Erlang(α, float(θ))

@kwdispatch (::Type{D})(;alpha=>α, shape=>α, theta=>θ, scale=>θ, beta=>β, rate=>β) where {D<:Erlang} begin
    (α, θ) -> D(α,θ)
    (α) -> D(α,1)
    (θ) -> D(1,θ)
    () -> D(1,1)
end

@distr_support Erlang 0.0 Inf

#### Conversions
function convert(::Type{Erlang{T}}, α::Int, θ::S) where {T <: Real, S <: Real}
    Erlang(α, T(θ))
end
function convert(::Type{Erlang{T}}, d::Erlang{S}) where {T <: Real, S <: Real}
    Erlang(d.α, T(d.θ))
end

#### Parameters

shape(d::Erlang) = d.α
scale(d::Erlang) = d.θ
rate(d::Erlang) = inv(d.θ)
params(d::Erlang) = (d.α, d.θ)
@inline partype(d::Erlang{T}) where {T<:Real} = T

#### Statistics

mean(d::Erlang) = d.α * d.θ
var(d::Erlang) = d.α * d.θ^2
skewness(d::Erlang) = 2 / sqrt(d.α)
kurtosis(d::Erlang) = 6 / d.α

function mode(d::Erlang)
    (α, θ) = params(d)
    α >= 1 ? θ * (α - 1) : error("Erlang has no mode when α < 1")
end

function entropy(d::Erlang)
    (α, θ) = params(d)
    α + lgamma(α) + (1 - α) * digamma(α) + log(θ)
end

mgf(d::Erlang, t::Real) = (1 - t * d.θ)^(-d.α)
cf(d::Erlang, t::Real)  = (1 - im * t * d.θ)^(-d.α)


#### Evaluation & Sampling

@_delegate_statsfuns Erlang gamma α θ

rand(d::Erlang) = StatsFuns.RFunctions.gammarand(d.α, d.θ)
