(* ::Package:: *)

(* ::Chapter:: *)
(*TeukolskyMode*)


BeginPackage["Teukolsky`TeukolskyMode`",
	{"Teukolsky`TeukolskySource`",
	 "Teukolsky`TeukolskyRadial`",
	 "Teukolsky`ConvolveSource`",
	 "KerrGeodesics`KerrGeoOrbit`",
	 "KerrGeodesics`OrbitalFrequencies`",
	 "SpinWeightedSpheroidalHarmonics`"}
];

TeukolskyModeObject::usage = "TeukolskyModeObject[assoc] an object which contains a Teukolsky mode"

TeukolskyPointParticleMode::usage = "TeukolskyPointParticleMode[s, l, m, n, k, orbit] Solve the Teukolsky equation with a point particle source"

Begin["`Private`"];


TeukolskyPointParticleMode[s_Integer, l_Integer, m_Integer, n_Integer, k_Integer, orbit_KerrGeoOrbitFunction] := Module[{source},
	source = TeukolskyPointParticleSource[s, orbit];
	TeukolskyPointParticleMode[s,l,m,n,k,orbit,source]
]

TeukolskyPointParticleMode[s_Integer, l_Integer, m_Integer, n_Integer, k_Integer, orbit_KerrGeoOrbitFunction, source_TeukolskySourceObject]:=Module[{M=1, assoc, R, S, \[Omega], \[CapitalOmega]r, \[CapitalOmega]\[Phi], \[CapitalOmega]\[Theta], Z, a, \[Lambda], AbsCSq, Fluxes, rh, \[Epsilon], \[Kappa], \[CapitalOmega]h, \[Alpha], FluxInf, FluxHor},

(*{\[CapitalOmega]r, \[CapitalOmega]\[Theta], \[CapitalOmega]\[Phi]} = orbit["Frequencies"];*) (*This gives Mino frequencies, need BL frequencies*)

{\[CapitalOmega]r, \[CapitalOmega]\[Theta], \[CapitalOmega]\[Phi]} = Values[KerrGeoFrequencies[orbit["a"], orbit["p"], orbit["e"], orbit["Inclination"]]];

\[Omega] = m \[CapitalOmega]\[Phi] + n \[CapitalOmega]r + k \[CapitalOmega]\[Theta];

a = orbit[[1]]; (*FIXME: should be able to get parameters from the orbit via assocication*)

R = TeukolskyRadial[s, l, m, a, \[Omega]];  

\[Lambda] = R["Eigenvalue"];

S = SpinWeightedSpheroidalHarmonicS[s, l, m, a \[Omega]];

Z = Teukolsky`ConvolveSource`Private`ConvolveSource[R, S, source];

rh = M + Sqrt[M^2-a^2];
\[CapitalOmega]h = a/(2 M rh);
\[Kappa] = \[Omega] - m \[CapitalOmega]h;
\[Epsilon] = Sqrt[M^2-a^2]/(4 M rh);

AbsCSq = ((\[Lambda]+2)^2 + 4 a m \[Omega] - 4a^2 \[Omega]^2)(\[Lambda]^2+36 m a \[Omega] - 36 a^2 \[Omega]^2) + (2\[Lambda]+3)(96 a^2 \[Omega]^2 - 48 m a \[Omega]) + 144 \[Omega]^2 (M^2-a^2);

\[Alpha] = (256(2M rh)^5 \[Kappa](\[Kappa]^2+4\[Epsilon]^2)(\[Kappa]^2+16\[Epsilon]^2)\[Omega]^3)/AbsCSq;

FluxInf =  Abs[Z["ZInf"]]^2/(4 \[Pi] \[Omega]^2);
FluxHor = \[Alpha] Abs[Z["ZHor"]]^2/(4 \[Pi] \[Omega]^2);

Fluxes = <|"FluxInf" -> FluxInf, "FluxHor" -> FluxHor, "FluxTotal" -> FluxInf + FluxHor |>;

assoc = <| "s" -> s, 
		   "l" -> l,
		   "m" -> m,
		   "n" -> n,
		   "k" -> k,
		   "\[Omega]" -> \[Omega],
		    "Type" -> "PointParticle", 
		    "Radial" -> R,
		    "Angular" -> S,
		    "Amplitudes" -> Z,
		    "Fluxes" -> Fluxes,
		    "Eigenvalue" -> R["Eigenvalue"]
		    |>;

TeukolskyModeObject[assoc]
]


Format[TeukolskyModeObject[assoc_]] := "TeukolskyModeObject["<>ToString[assoc["s"]]<>","<>ToString[assoc["l"]]<>","<>ToString[assoc["m"]]<>","<>ToString[assoc["n"]]<>","<>ToString[assoc["k"]]<>",<<>>]";

TeukolskyModeObject[assoc_][string_] := assoc[string]


End[];
EndPackage[];
