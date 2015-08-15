open Kulfi_Routing
open Frenetic_Network
open Net
open Kulfi_Ecmp
open Kulfi_Mcf
open Kulfi_Mw
open Kulfi_Raeke
open Kulfi_Spf
open Kulfi_Vlb
open Kulfi_Types
open Kulfi_Util

module VertexSet = Topology.VertexSet

let create_topology_and_demands () =
  let topo = Parse.from_dotfile "./data/3cycle.dot" in
  let host_set = VertexSet.filter (Topology.vertexes topo)
                                  ~f:(fun v ->
                                      let label = Topology.vertex_to_label topo v in
                                      Node.device label = Node.Host) in
  let hs = Topology.VertexSet.elements host_set in
  let hosts = Array.of_list hs in
  let num_hosts = List.length hs in
  let demands = Array.make_matrix num_hosts num_hosts 1.0 in
  let pairs =
    let lst = ref [] in
    Array.iteri (fun i h_i ->
                 Array.iteri (fun j h_j ->
                              let demand = demands.(i).(j) in
                              if i = j || demand = 0.0 then () else
                                lst := (hosts.(i), hosts.(j), demand)::(!lst))
                             hosts)
                hosts;
    !lst
  in
  Printf.printf "# hosts = %d\n" (Topology.VertexSet.length host_set);
  Printf.printf "# pairs = %d\n" (List.length pairs);
  Printf.printf "# total vertices = %d\n" (Topology.num_vertexes topo);
  (hosts,topo,pairs)

let test_ecmp = false

let test_mcf = 
  let (hosts,topo,pairs) = create_topology_and_demands () in
  let scheme = 
    Kulfi_Mcf.solve topo pairs SrcDstMap.empty in
  let h1 = Array.get hosts 0  in 
  let h2 = Array.get hosts 1  in
  let sum_of_probs = 
    match SrcDstMap.find scheme (h1,h2) with
    | None -> assert false
    | Some paths ->
       PathMap.fold paths ~init:0.0 ~f:(fun ~key:p ~data:s acc -> s +. acc) in
  Printf.printf "sum of prob=%f\n" sum_of_probs;
  (sum_of_probs > 0.9) && (sum_of_probs < 1.1)
                 
let test_mw = false

let test_raeke = false
   
let test_spf =
  let (hosts,topo,pairs) = create_topology_and_demands () in
  let scheme = 
    Kulfi_Spf.solve topo pairs SrcDstMap.empty in
  let h1 = Array.get hosts 0  in 
  let h2 = Array.get hosts 1  in

  (* TODO(jnf,rjs): could just call sample_scheme here? *)
  let x = match SrcDstMap.find scheme (h1,h2)  with | None -> assert false | Some x -> x in
  let path = sample_dist x in
  (List.length path) == 3
    
let test_vlb =
  let (hosts,topo,pairs) = create_topology_and_demands () in
  let scheme = 
    Kulfi_Vlb.solve topo pairs SrcDstMap.empty in
  let h1 = Array.get hosts 0  in 
  let h2 = Array.get hosts 1  in
  let paths = match SrcDstMap.find scheme (h1,h2) with | None -> assert false | Some x -> x in
  Printf.printf "VLB set length =%d\n"  (PathMap.length paths);
  (* Printf.printf "%s\n" (dump_scheme topo scheme); *)
  (PathMap.length paths) == 2
                         
TEST "ecmp" = test_ecmp = true

TEST "mcf" = test_mcf = true

TEST "mw" = test_mw = true

TEST "raeke" = test_raeke = true

TEST "spf" = test_spf = true

TEST "vlb" = test_vlb = true

               

