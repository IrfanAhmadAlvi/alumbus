const functions = require("firebase-functions");
const admin = require("firebase-admin");
const cloudinary = require("cloudinary").v2;

admin.initializeApp();

// Configure Cloudinary with your credentials from environment variables
cloudinary.config({
  cloud_name: functions.config().cloudinary.cloud_name,
  api_key: functions.config().cloudinary.api_key,
  api_secret: functions.config().cloudinary.api_secret,
});

/**
 * This function triggers when a document in the 'notices' collection is deleted.
 * It then deletes the corresponding file from Cloudinary storage.
 */
exports.onNoticeDeleted = functions.firestore
  .document("notices/{noticeId}")
  .onDelete(async (snap, context) => {
    const deletedData = snap.data();
    const fileUrl = deletedData.downloadUrl;

    if (!fileUrl) {
      console.log(`Document ${context.params.noticeId} had no downloadUrl.`);
      return null;
    }

    // --- IMPROVED LOGIC ---
    try {
      // 1. Extract the public_id from the URL (e.g., "notices/my_file")
      const publicIdWithFolder = fileUrl.split("/").slice(-2).join("/");
      const publicId = publicIdWithFolder.substring(
        0,
        publicIdWithFolder.lastIndexOf(".")
      );

      // 2. Determine the resource type based on file extension
      const fileExtension = fileUrl.split(".").pop().toLowerCase();
      let resourceType = "raw"; // Default for PDF, DOC, etc.
      if (["jpg", "jpeg", "png", "gif"].includes(fileExtension)) {
        resourceType = "image";
      } else if (["mp4", "mov", "avi"].includes(fileExtension)) {
        resourceType = "video";
      }

      console.log(`Attempting to delete from Cloudinary. Public ID: ${publicId}, Resource Type: ${resourceType}`);

      // 3. Use the Cloudinary Admin API to delete the file
      const result = await cloudinary.uploader.destroy(publicId, {
        resource_type: resourceType,
      });

      console.log("Cloudinary deletion result:", result);

    } catch (error) {
      console.error("Error deleting from Cloudinary:", error);
    }

    return null;
  });