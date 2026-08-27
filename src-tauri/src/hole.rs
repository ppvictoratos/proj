use serde::{Deserialize, Serialize};
use crate::collision::{Wall, Hole};
use crate::physics::Vec2;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HoleLayout {
    pub id: u32,
    pub name: String,
    pub start_pos: Vec2,
    pub walls: Vec<Wall>,
    pub holes: Vec<Hole>,
}

pub fn create_uturn_hole() -> HoleLayout {
    HoleLayout {
        id: 1,
        name: "U-Turn".to_string(),
        start_pos: Vec2::new(150.0, 600.0),
        walls: vec![
            // Left outer wall of U
            Wall { x1: 80.0, y1: 120.0, x2: 80.0, y2: 400.0 },
            // Bottom curve of U
            Wall { x1: 80.0, y1: 400.0, x2: 200.0, y2: 450.0 },
            Wall { x1: 200.0, y1: 450.0, x2: 400.0, y2: 420.0 },
            // Right outer wall of U
            Wall { x1: 420.0, y1: 420.0, x2: 420.0, y2: 120.0 },
            // Top boundaries
            Wall { x1: 50.0, y1: 120.0, x2: 80.0, y2: 120.0 },
            Wall { x1: 420.0, y1: 120.0, x2: 450.0, y2: 120.0 },
            // Right curve
            Wall { x1: 450.0, y1: 120.0, x2: 500.0, y2: 180.0 },
            Wall { x1: 500.0, y1: 180.0, x2: 520.0, y2: 300.0 },
            // Left curve
            Wall { x1: 50.0, y1: 120.0, x2: 20.0, y2: 180.0 },
            Wall { x1: 20.0, y1: 180.0, x2: 10.0, y2: 300.0 },
            // Bottom boundary
            Wall { x1: 10.0, y1: 300.0, x2: 10.0, y2: 650.0 },
            Wall { x1: 10.0, y1: 650.0, x2: 300.0, y2: 650.0 },
            Wall { x1: 300.0, y1: 650.0, x2: 520.0, y2: 650.0 },
            Wall { x1: 520.0, y1: 650.0, x2: 520.0, y2: 300.0 },
        ],
        holes: vec![
            // Left hole
            Hole {
                x: 40.0,
                y: 300.0,
                radius: 25.0,
                id: 1,
            },
            // Middle hole
            Hole {
                x: 250.0,
                y: 380.0,
                radius: 25.0,
                id: 2,
            },
            // Right hole (goal)
            Hole {
                x: 480.0,
                y: 300.0,
                radius: 25.0,
                id: 3,
            },
        ],
    }
}

pub fn get_hole_by_id(id: u32) -> Option<HoleLayout> {
    match id {
        1 => Some(create_uturn_hole()),
        _ => None,
    }
}
