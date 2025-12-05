import Mood from '../models/mood.js';

export const createOrUpdateMood = async (req, res) => {
  try {
    const { userId, mood, reason, sleep, physical } = req.body;
    
    if (!userId || !mood) {
      return res.status(400).json({ message: "User ID and mood keyword are required." });
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0); // Start of today

    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1); // Start of tomorrow

    const updatedMood = await Mood.findOneAndUpdate(
      {
        user: userId,
        createdAt: { $gte: today, $lt: tomorrow } // Query for today's entry
      },
      {
        $set: { mood: mood, reason: reason, user: userId, sleep:sleep || 5, physical: physical || 5 } // Data to set on update or create
      },
      {
        upsert: true, // IMPORTANT: Create the document if it doesn't exist
        new: true,    // IMPORTANT: Return the new/updated document
        setDefaultsOnInsert: true
      }
    );

    console.log(`SUCCESS: Mood saved for user ${userId}. Mood: ${mood}, Sleep: ${sleep}, Phys: ${physical}`);

    res.status(200).json({
      message: "Daily stats saved successfully",
      data: updatedMood
    });

  } catch (error) {
    console.error("Error in createOrUpdateMood:", error);
    res.status(500).json({ message: "Server error while saving mood", error: error.message });
  }
};


export const getMoodHistory = async (req, res) => {
  try {
    // req.user.id comes from the 'protect' middleware
    const userId = req.user.id; 

    // Fetch all moods for this user, sorted by date (newest first)
    const moods = await Mood.find({ user: userId })
      .sort({ createdAt: -1 })
      .select('mood reason sleep physical createdAt'); // We only need these fields

    res.status(200).json(moods);
  } catch (error) {
    console.error("Error fetching mood history:", error);
    res.status(500).json({ message: "Server error fetching moods" });
  }
};

export const getTodaysMoodByUserId = async (req, res) => {
  try {
    const userId = req.params.userId;

    if (!userId) {
      return res.status(400).json({ message: "User ID is required." });
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const mood = await Mood.findOne({
      user: userId,
      createdAt: { $gte: today, $lt: tomorrow }
    });

    res.status(200).json(mood || { message: "No mood logged for today." });

  } catch (error) {
    console.error("Error fetching today's mood:", error);
    res.status(500).json({ message: "Server error fetching today's mood" });
  }
};
