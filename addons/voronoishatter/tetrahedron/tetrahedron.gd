extends Object

class_name Tetrahedron
# Use float epsilon consistent with Vector3 precision
const EPSILON: float = 1e-5

var vertices: Array[Vector3] = []
var indices: Array[int] = []

func try_calculate_tetrahedron_circumcenter() -> Vector3:
    if vertices == null or len(vertices) != 4:
        VoronoiLog.err("try_calculate_tetrahedron_circumcenter: Invalid vertices in input.")
        return Vector3.INF

    var a: Vector3 = vertices[0]
    var b: Vector3 = vertices[1]
    var c: Vector3 = vertices[2]
    var d: Vector3 = vertices[3]

    # Use coordinates relative to point 'a'. Use float consistently.
    var ba: Vector3 = b - a
    var ca: Vector3 = c - a
    var da: Vector3 = d - a

    # Use length_squared()
    var len_ba_sq: float = ba.length_squared()
    var len_ca_sq: float = ca.length_squared()
    var len_da_sq: float = da.length_squared()

    # cross products
    var cross_cd: Vector3 = ca.cross(da)
    var cross_db: Vector3 = da.cross(ba)
    var cross_bc: Vector3 = ba.cross(ca)

    # Scalar triple product (volume related) is float
    var scalar_triple_product: float = ba.dot(cross_cd)

    # Check for degenerate or near-degenerate tetrahedron
    if abs(scalar_triple_product) < EPSILON:
        return Vector3.INF # Return inf for degenerate cases

    # Denominator calculation using float
    var denominator_inv = 0.5 / scalar_triple_product

    # Calculate offset using float operations
    var circ_relative: Vector3 = (cross_cd * len_ba_sq + cross_db * len_ca_sq + cross_bc * len_da_sq) * denominator_inv

    # Absolute circumcenter
    var circumcenter: Vector3 = a + circ_relative

    return circumcenter
