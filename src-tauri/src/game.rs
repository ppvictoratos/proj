use serde::{Deserialize, Serialize};
use crate::physics::{Ball, Vec2};
use crate::hole::HoleLayout;
use crate::collision::check_hole_collision;

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(crate = "serde")]
pub struct GameState {
    pub ball: Ball,
    pub hole_layout: HoleLayout,
    pub ball_sunk: Option<u32>,
    pub time_elapsed: f32,
    pub power: f32,
    pub angle: f32,
}

impl GameState {
    pub fn new(hole_layout: HoleLayout) -> Self {
        GameState {
            ball: Ball::new(hole_layout.start_pos.x, hole_layout.start_pos.y),
            hole_layout: hole_layout.clone(),
            ball_sunk: None,
            time_elapsed: 0.0,
            power: 0.0,
            angle: 0.0,
        }
    }

    pub fn update(&mut self, dt: f32) {
        if self.ball_sunk.is_some() {
            return;
        }

        self.time_elapsed += dt;
        self.ball.update(dt);

        for wall in &self.hole_layout.walls {
            if let Some(normal) = wall.collides_with_ball(&self.ball) {
                let mut ball = self.ball.clone();
                wall.resolve_collision(&mut ball, normal);
                self.ball = ball;
            }
        }

        for hole in &self.hole_layout.holes {
            if check_hole_collision(&self.ball, hole) {
                self.ball_sunk = Some(hole.id);
            }
        }

        if self.ball.position.y > 500.0 {
            self.ball.velocity = Vec2::zero();
            self.ball.position.y = 500.0;
        }
    }

    pub fn strike(&mut self, angle: f32, power: f32) {
        if self.ball_sunk.is_some() {
            return;
        }

        let force_magnitude = power * 500.0;
        self.ball.velocity = Vec2::new(
            angle.cos() * force_magnitude,
            angle.sin() * force_magnitude,
        );
    }

    pub fn reset(&mut self) {
        self.ball = Ball::new(
            self.hole_layout.start_pos.x,
            self.hole_layout.start_pos.y,
        );
        self.ball_sunk = None;
        self.time_elapsed = 0.0;
    }
}
