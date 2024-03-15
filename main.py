import os
import uuid
from telethon import TelegramClient, events
from tg_bot_config import api_hash, api_id, bot_token

class RealESRGANBot:
    def __init__(self, api_id, api_hash, bot_token):
        self.client = TelegramClient('bot', api_id, api_hash).start(bot_token=bot_token)
        self.model = "realesr-animevideov3"
        self.model_list = [
            "realesr-animevideov3", "realesrgan-x4plus", "realesrgan-x4plus-anime", "realesrnet-x4plus"
        ]
        self.supported_file_endings = (".jpg", ".png", ".webp")
        self.setup_handlers()

    def setup_handlers(self):
        @self.client.on(events.NewMessage(incoming=True))
        async def handle_message(event):
            if event.message.media:
                await self.process_media_message(event)
            else:
                await self.process_command_message(event)

    async def process_media_message(self, event):
        name = str(uuid.uuid4())
        oldfilename = await event.message.download_media(name)
        file_end = os.path.splitext(oldfilename)[1]
        if file_end in self.supported_file_endings:
            output_file = f"./{name}_out{file_end}"
            os.system(f"realesrgan-ncnn-vulkan -i ./{name}{file_end} -o {output_file} -n {self.model}")
            await event.reply(force_document=True, file=output_file)
            os.remove(f"./{name}{file_end}")
            os.remove(output_file)
        else:
            print("Invalid incoming photo")

    async def process_command_message(self, event):
        text = event.raw_text
        if text == "/clean_cache":
            for ext in self.supported_file_endings:
                os.system(f"rm ./*{ext}")
            print("Cache cleaned")
        elif text == "/ava_model":
            await event.reply(f"目前的模型是 {self.model}, 可用模型: " + " | ".join(self.model_list))
        elif text.startswith("/model"):
            model = text.split(maxsplit=1)[1] if len(text.split(maxsplit=1)) > 1 else ""
            if model in self.model_list:
                self.model = model
                await event.reply(f"成功切换模型到: {self.model}")
            else:
                await event.reply("不支持的模型")
        elif text == "/help":
            await event.reply('''本Bot服务器由 Vultr 提供
由衷感谢Real-ESRGAN
Real-ESRGAN项目地址: https://github.com/xinntao/Real-ESRGAN
本项目地址: https://github.com/keep1earning/Real-ESRGAN-TG-bot
''')

    def run(self):
        self.client.start()
        self.client.run_until_disconnected()

if __name__ == "__main__":
    bot = RealESRGANBot(api_id, api_hash, bot_token)
    bot.run()
