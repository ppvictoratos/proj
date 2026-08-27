use serde::{Deserialize, Serialize};
use crate::physics::{Ball, Vec2};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Wall {
    pub x1: f32,
    pub y1: f32,
    pub x2: f32,
    pub y2: f32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Hole {
    pub x: f32,
    pub y: f32,
    pub radius: f32,
    pub id: u32,
}

impl Wall {
    pub fn collides_with_ball(&self, ball: &Ball) -> Option<Vec2> {
        let dx = self.x2 - self.x1;
        let dy = self.y2 - self.y1;
        let len_sq = dx * dx + dy * dy;

        if len_sq == 0.0 {
            return None;
        }

        let t = ((ball.position.x - self.x1) * dx + (ball.position.y - self.y1) * dy) / len_sq;
        let t = t.clamp(0.0, 1.0);

        let closest_x = self.x1 + t * dx;
        let closest_y = self.y1 + t * dy;

        let dist_x = ball.position.x - closest_x;
        let dist_y = ball.position.y - closest_y;
        let dist = (dist_x * dist_x + dist_y * dist_y).sqrt();

        if dist < ball.radius {
            let normal = Vec2::new(dist_x, dist_y).normalize();
            Some(normal)
        } else {
            None
        }
    }

    pub fn resolve_collision(&self, ball: &mut Ball, normal: Vec2) {
        const BOUNCE: f32 = 0.6;
        let bounce = ball.velocity.dot(normal) * BOUNCE;
        ball.velocity = ball.velocity.add(normal.scale(-bounce * 2.0));

        let overlap = ball.radius - normal.scale(-ball.radius).magnitude();
        ball.position = ball.position.add(normal.scale(overlap + 1.0));
    }
}

pub fn check_hole_collision(ball: &Ball, hole: &Hole) -> bool {
    let dx = ball.position.x - hole.x;
    let dy = ball.position.y - hole.y;
    let dist = (dx * dx + dy * dy).sqrt();
    dist < hole.radius
}
