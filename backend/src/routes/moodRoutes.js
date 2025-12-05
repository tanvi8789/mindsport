import { Router } from 'express';
import { createOrUpdateMood, getMoodHistory } from '../controllers/moodController.js';
// --- THIS WAS MISSING ---
import { protect } from '../middleware/auth.js'; 

const router = Router();

// POST /api/moods -> Save today's mood
router.route('/').post(createOrUpdateMood);

// GET /api/moods/history -> Get all past moods
// Now 'protect' is defined and this will work
router.route('/history').get(protect, getMoodHistory);

import { getTodaysMoodByUserId } from '../controllers/moodController.js';

router.get('/today/:userId', getTodaysMoodByUserId);


export default router;