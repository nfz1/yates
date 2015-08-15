open Frenetic_Network
open Net
open Core.Std
       
type topology = Net.Topology.t

type demand = float

type demand_pair = Topology.vertex * Topology.vertex * demand

type demands = demand_pair list

type edge = Net.Topology.edge with sexp

type path = edge list with sexp

type probability = float with sexp

module PathOrd = struct
  type t = path with sexp
  let compare = Pervasives.compare                    
end

module PathMap = Map.Make(PathOrd)

type tag = int

module Tag = Int

module TagMap = Map.Make(Tag)
                             
module SrcDstOrd = struct
  type t = Topology.vertex * Topology.vertex with sexp
  let compare = Pervasives.compare                                      
end

module SrcDstMap = Map.Make(SrcDstOrd)

type scheme = (probability PathMap.t) SrcDstMap.t

type configuration = (probability TagMap.t) SrcDstMap.t
             
(* A Routing Scheme is an object that describes a prob distribution over paths. 
   It supports an interface to lets one draw a random sample, and a way to compare
   to other routing schemes, for example, if we want to minimize differences  *)

let sample_dist (path_dist:probability PathMap.t) : path = assert false

let compare_scheme (s1:scheme) (s2:scheme) : int = assert false
