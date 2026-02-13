"""
Semantic Memory MCP Server for Claude Code Development Framework.

Stores and retrieves memories using ChromaDB for semantic search.
Memories persist across sessions at ~/.claude/memory/chroma_db/
"""

import os
import uuid
from datetime import datetime, timezone

import chromadb
from mcp.server.fastmcp import FastMCP

# --- Setup ---

DB_PATH = os.path.join(os.path.expanduser("~"), ".claude", "memory", "chroma_db")
os.makedirs(DB_PATH, exist_ok=True)

client = chromadb.PersistentClient(path=DB_PATH)
collection = client.get_or_create_collection(
    name="memories",
    metadata={"hnsw:space": "cosine"},
)

mcp = FastMCP("memory-server")

VALID_TYPES = ["decision", "error", "preference", "pattern", "context"]


def _short_id() -> str:
    return uuid.uuid4().hex[:8]


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


# --- Tools ---


@mcp.tool()
def memory_save(
    content: str,
    type: str = "context",
    tags: str = "",
    project: str = "",
) -> str:
    """Save a memory for later retrieval by meaning.

    Args:
        content: The text to remember (be descriptive and self-contained).
        type: Category — one of: decision, error, preference, pattern, context.
        tags: Comma-separated tags for filtering (e.g. "auth,login,bug").
        project: Project name (leave empty for global memories).
    """
    if type not in VALID_TYPES:
        return f"Invalid type '{type}'. Must be one of: {', '.join(VALID_TYPES)}"

    memory_id = _short_id()
    collection.add(
        ids=[memory_id],
        documents=[content],
        metadatas=[
            {
                "type": type,
                "tags": tags,
                "project": project,
                "created_at": _now(),
            }
        ],
    )
    return f"Saved memory {memory_id} (type={type}, project={project or 'global'})"


@mcp.tool()
def memory_search(query: str, limit: int = 5) -> str:
    """Find memories by meaning using semantic search.

    Args:
        query: What you're looking for, described naturally.
        limit: Maximum number of results (default 5).
    """
    total = collection.count()
    if total == 0:
        return "No memories found. The memory database is empty."

    results = collection.query(
        query_texts=[query],
        n_results=min(limit, total),
    )

    if not results["ids"][0]:
        return "No matching memories found."

    lines = []
    for i, memory_id in enumerate(results["ids"][0]):
        meta = results["metadatas"][0][i]
        doc = results["documents"][0][i]
        dist = results["distances"][0][i] if results.get("distances") else None
        score = f" (similarity: {1 - dist:.2f})" if dist is not None else ""
        lines.append(
            f"**[{memory_id}]** ({meta['type']}) {score}\n"
            f"  Project: {meta.get('project') or 'global'} | "
            f"Tags: {meta.get('tags') or 'none'} | "
            f"Created: {meta.get('created_at', 'unknown')}\n"
            f"  {doc}"
        )

    return f"Found {len(lines)} memories:\n\n" + "\n\n".join(lines)


@mcp.tool()
def memory_query(
    type: str = "",
    project: str = "",
    tags: str = "",
    limit: int = 10,
) -> str:
    """Filter memories by metadata (type, project, tags).

    Args:
        type: Filter by type (decision, error, preference, pattern, context).
        project: Filter by project name.
        tags: Filter by tag (matches if the tag appears in the tags string).
        limit: Maximum number of results (default 10).
    """
    total = collection.count()
    if total == 0:
        return "No memories found. The memory database is empty."

    where_clauses = []
    if type:
        if type not in VALID_TYPES:
            return f"Invalid type '{type}'. Must be one of: {', '.join(VALID_TYPES)}"
        where_clauses.append({"type": {"$eq": type}})
    if project:
        where_clauses.append({"project": {"$eq": project}})
    if tags:
        where_clauses.append({"tags": {"$contains": tags}})

    where = None
    if len(where_clauses) == 1:
        where = where_clauses[0]
    elif len(where_clauses) > 1:
        where = {"$and": where_clauses}

    results = collection.get(
        where=where,
        limit=limit,
    )

    if not results["ids"]:
        filters = []
        if type:
            filters.append(f"type={type}")
        if project:
            filters.append(f"project={project}")
        if tags:
            filters.append(f"tags={tags}")
        return f"No memories found matching: {', '.join(filters)}"

    lines = []
    for i, memory_id in enumerate(results["ids"]):
        meta = results["metadatas"][i]
        doc = results["documents"][i]
        lines.append(
            f"**[{memory_id}]** ({meta['type']})\n"
            f"  Project: {meta.get('project') or 'global'} | "
            f"Tags: {meta.get('tags') or 'none'} | "
            f"Created: {meta.get('created_at', 'unknown')}\n"
            f"  {doc}"
        )

    return f"Found {len(lines)} memories:\n\n" + "\n\n".join(lines)


@mcp.tool()
def memory_list(type: str = "", project: str = "", limit: int = 10) -> str:
    """Browse recent memories, optionally filtered by type or project.

    Args:
        type: Filter by type (decision, error, preference, pattern, context).
        project: Filter by project name.
        limit: Maximum number of results (default 10).
    """
    return memory_query(type=type, project=project, limit=limit)


@mcp.tool()
def memory_delete(id: str) -> str:
    """Delete a memory by its ID.

    Args:
        id: The 8-character memory ID (shown in brackets in search results).
    """
    existing = collection.get(ids=[id])
    if not existing["ids"]:
        return f"Memory '{id}' not found."

    collection.delete(ids=[id])
    return f"Deleted memory {id}."


# --- Run ---

if __name__ == "__main__":
    mcp.run()
