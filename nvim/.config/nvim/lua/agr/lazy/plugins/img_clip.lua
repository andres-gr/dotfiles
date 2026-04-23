local I = {
  'HakonHarnes/img-clip.nvim',
  event = 'VeryLazy',
  opts = {
    default = {
      drag_and_drop = {
        insert_mode = true,
      },
      embed_image_as_base64 = false,
      prompt_for_file_name = false,
    },
  },
}

return I
