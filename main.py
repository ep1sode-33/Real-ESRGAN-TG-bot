import os
import uuid
import json
from retrying import retry
from telethon import TelegramClient, events
from tg_bot_config import api_hash, api_id, bot_token
global model_list
model_list = ["realesr-animevideov3","realesrgan-x4plus","realesrgan-x4plus-anime","realesrnet-x4plus"]
global models
models = "realesr-animevideov3"
client = TelegramClient('bot', api_id, api_hash).start(bot_token=bot_token)
@client.on(events.NewMessage(incoming=True))
async def my_event_handler(event):
    if event.message.media != None:
        name = str(uuid.uuid4())
        oldfilename = await event.message.download_media(name)
        file_end = ""
        if oldfilename.endswith(".jpg"):
            file_end = ".jpg"
        else:
            if oldfilename.endswith(".png"):
                file_end = ".png"
            else:
                if oldfilename.endswith(".webp"):
                    file_end = ".webp"
        if file_end != "":
            os.system("realesrgan-ncnn-vulkan" + " -i" + " ./" + name + file_end + " -o" + " ./" + name + "_out" + file_end + " -n " + models)
            await event.reply(force_document=True,file=("./" + name + "_out" + file_end))
            os.remove("./" + name + file_end)
            os.remove("./" + name + "_out" + file_end)
        else:
            print("invalid incoming photo")
    else:
        if event.raw_text == "/clean_cache":
            os.system("rm ./*.jpg")
            os.system("rm ./*.png")
            os.system("rm ./*.webp")
            print("Cache cleaned")
        if event.raw_text == "/ava_model":
            await event.reply("目前的模型是 " + models + " , 可用模型: realesr-animevideov3 | realesrgan-x4plus | realesrgan-x4plus-anime | realesrnet-x4plus")
        if event.raw_text[:6] == "/model":
            if event.raw_text[7:] in model_list:
                model = event.raw_text[7:]
                await event.reply("成功切换模型到: " + models)
            else:
                await event.reply("不支持的模型")
        if event.raw_text == "/help":
            await event.reply('''           本Bot服务器由 Vultr 提供
            由衷感谢Real-ESRGAN
            Real-ESRGAN项目地址: https://github.com/xinntao/Real-ESRGAN
            本项目地址: https://github.com/keep1earning/Real-ESRGAN-TG-bot
            ''')

client.start()
client.run_until_disconnected()
