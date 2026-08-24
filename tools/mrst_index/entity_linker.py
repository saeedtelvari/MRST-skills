"""
Entity Linker: High-speed linking between book explanations and MRST source code symbols & physical concepts.
"""
import re
from typing import List, Dict, Any, Tuple
from .book_chunker import BookChunk
from .source_indexer import SourceChunk

COMMON_STOP_WORDS = {
    "contents", "run", "test", "demo", "setup", "example", "examples", "get", "set", "init",
    "main", "plot", "display", "check", "clear", "error", "warning", "info", "help", "license",
    "copying", "readme", "util", "utils", "temp", "data", "load", "save", "print", "figure",
    "true", "false", "cell", "grid", "time", "step", "fluid", "rock", "model", "state", "deck"
}

DOMAIN_CONCEPTS = [
    ("tpfa", "Two-Point Flux Approximation", "Classical finite-volume discretization for elliptic/parabolic flow"),
    ("mpfa", "Multi-Point Flux Approximation", "Consistent flux approximation for full-tensor permeability or non-orthogonal grids"),
    ("mimetic", "Mimetic Finite Difference Method", "Discretization preserving vector calculus properties on general polyhedral cells"),
    ("ad_oo", "Automatic Differentiation Object-Oriented (AD-OO)", "Core MRST framework for auto-differentiated reservoir simulation"),
    ("black_oil", "Black-Oil Model", "Three-phase (oil, water, gas) formulation with dissolved gas and vaporized oil"),
    ("compositional", "Compositional Flow Model", "Equation-of-state based multi-component multi-phase reservoir simulator"),
    ("msrsb", "Multiscale Restricted Smoothed Basis (MsRSB)", "Multiscale method using smoothed prolongation operators for highly heterogeneous media"),
    ("msfvm", "Multiscale Finite Volume Method (MsFVM)", "Dual coarse-grid multiscale pressure solver"),
    ("dfm", "Discrete Fracture Matrix (DFM)", "Explicit lower-dimensional fracture network modeling"),
    ("edfm", "Embedded Discrete Fracture Model (EDFM/pEDFM)", "Non-conforming fracture network modeling using non-neighboring connections"),
    ("ve_model", "Vertical Equilibrium (VE) Model", "Dimensionally-reduced fast simulation for CO2 storage aquifers"),
    ("pebi", "Perpendicular Bisection (PEBI) / Voronoi Gridding", "Unstructured Voronoi gridding conforming to faults and wellbores"),
    ("cpr_preconditioner", "Constrained Pressure Residual (CPR)", "Two-stage preconditioner decoupling pressure and saturation for linear solvers"),
    ("biot_poroelasticity", "Biot Poroelasticity", "Coupled mechanics and fluid flow in deformable porous media")
]

def build_symbol_map(source_chunks: List[SourceChunk]) -> Dict[str, List[SourceChunk]]:
    symbol_map: Dict[str, List[SourceChunk]] = {}
    for sc in source_chunks:
        name = sc.symbol_name
        if len(name) < 4 or name.lower() in COMMON_STOP_WORDS:
            continue
        if name not in symbol_map:
            symbol_map[name] = []
        symbol_map[name].append(sc)
    return symbol_map

def link_entities_and_relations(
    book_chunks: List[BookChunk],
    source_chunks: List[SourceChunk]
) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
    
    symbol_map = build_symbol_map(source_chunks)
    symbol_keys = set(symbol_map.keys())
    print(f"Built symbol map with {len(symbol_map)} candidate MRST API symbols.")

    entities: List[Dict[str, Any]] = []
    relations: List[Dict[str, Any]] = []
    
    # 1. Register domain concepts
    for cid, cname, cdesc in DOMAIN_CONCEPTS:
        entities.append({
            "entity_id": f"concept_{cid}",
            "name": cname,
            "entity_type": "concept",
            "description": cdesc,
            "source_ref": "MRST Literature & Architecture"
        })

    # 2. Register source symbols
    for name, s_list in symbol_map.items():
        primary = s_list[0]
        entities.append({
            "entity_id": f"symbol_{name.lower()}",
            "name": name,
            "entity_type": primary.symbol_type,
            "description": primary.h1_doc or primary.signature,
            "source_ref": primary.file_path
        })

    # 3. Match book chunks with source symbols & concepts
    rel_id_counter = 1
    seen_relations = set()

    for bc in book_chunks:
        content_lower = bc.content.lower()

        # Check concepts
        for cid, cname, _ in DOMAIN_CONCEPTS:
            term_clean = cid.replace("_", " ")
            if cid in content_lower or term_clean in content_lower or cname.lower() in content_lower:
                rel_key = (bc.chunk_id, f"concept_{cid}", "explains_concept")
                if rel_key not in seen_relations:
                    seen_relations.add(rel_key)
                    relations.append({
                        "rel_id": f"rel_{rel_id_counter:06d}",
                        "source_id": bc.chunk_id,
                        "target_id": f"concept_{cid}",
                        "relation_type": "explains_concept",
                        "confidence": 0.90,
                        "context": f"{bc.header_path}"
                    })
                    rel_id_counter += 1

        # Fast set intersection for source symbol mentions
        words_in_chunk = set(re.findall(r"\b[a-zA-Z0-9_]+\b", bc.content))
        matching_symbols = words_in_chunk & symbol_keys

        for sym_name in matching_symbols:
            for sc in symbol_map[sym_name]:
                rel_key = (bc.chunk_id, sc.source_id, "explains_code")
                if rel_key not in seen_relations:
                    seen_relations.add(rel_key)
                    relations.append({
                        "rel_id": f"rel_{rel_id_counter:06d}",
                        "source_id": bc.chunk_id,
                        "target_id": sc.source_id,
                        "relation_type": "explains_code",
                        "confidence": 0.95,
                        "context": f"Mentions {sym_name} in {bc.header_path}"
                    })
                    rel_id_counter += 1

    print(f"Extracted {len(entities)} entities and created {len(relations)} cross-reference relations.")
    return entities, relations
