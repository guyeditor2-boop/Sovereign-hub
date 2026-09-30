-- Sovereign Hub
-- Key-free build derived from the uploaded source.

getgenv().__SovereignHubPVPLaunchJobId = tostring(game.JobId)

local function func1(param1, param2)
	if os.clock() >= param2 then
		return false, nil, true
	end
	local flag1 = false
	local value1 = nil
	local value2 = nil

	local thread = task.spawn(function()
		local ok, result = pcall(param1)
		if flag1 then
			return
		end
		value1 = ok
		value2 = result
		flag1 = true
	end)

	while not flag1 do
		if param2 <= os.clock() then
			flag1 = true
			pcall(task.cancel, thread)
			return false, nil, true
		end

		task.wait(0.05)
	end

	return value1, value2, false
end

local function func2(flag2)
	if type(flag2) == "string" and flag2 ~= "" then
		return flag2
	end

	if type(flag2) ~= "table" then
		return nil
	end
	local statusCode = flag2.StatusCode

	if statusCode == nil then
		statusCode = flag2.status_code
	end

	if statusCode == nil then
		statusCode = flag2.Status
	end

	if statusCode == nil then
		statusCode = flag2.status
	end

	if statusCode ~= nil then
		local num1 = tonumber(statusCode)
		if not num1 or num1 < 200 or num1 >= 300 then
			return nil
		end
	end

	local body = flag2.Body or flag2.body
	if type(body) == "string" and body ~= "" then
		return body
	end
	return nil
end

local function func3(...) end

local function func4()
	return nil
end

local function func5()
	return nil
end

local function func6(r)local X,V=pcall(readfile,r);if X then return V;end;return nil;end
local function func7(r,X)if type(writefile)~="function"then return false;end;local V,N=pcall(writefile,r,X);return V and N~=false;end
local function func8(...) end
local tbl1 = { lite = true, full = true }

local function func9()
	local json = func6("Sovereign HubLoader_v1.json")
	if type(json) ~= "string" or json == "" then
		return nil, "missing"
	end

	local ok, result = pcall(function()
		return game:GetService("HttpService"):JSONDecode(json)
	end)

	if not ok or type(result) ~= "table" then
		return nil, "corrupt"
	end

	if result.version ~= 1 or type(result.rememberExperience) ~= "boolean" or not tbl1[result.experience] then
		return nil, "invalid"
	end
	return { version = 1, rememberExperience = result.rememberExperience, experience = result.experience }, nil
end

local function func10(param3, flag3)
	if not tbl1[param3] then
		return false
	end

	local ok, result = pcall(function()
		return game:GetService("HttpService"):JSONEncode({ version = 1, rememberExperience = flag3 == true, experience = param3 })
	end)

	if not ok then
		return false
	end
	local ok2, result2 = pcall(writefile, "Sovereign HubLoader_v1.json", result)
	return ok2 and result2 ~= false
end

local function func11()
	local flag4 = false

	pcall(function()
		local UserInputService = game:GetService("UserInputService")
		flag4 = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
	end)

	return flag4
end

local sovereignHubLanguageOptions = {
	{ code = "Auto", name = "Auto Detect" },
	{ code = "English", name = "English" },
	{ code = "Spanish", name = "Español" },
	{ code = "Portuguese", name = "Português (Brasil)" },
	{ code = "French", name = "Français" },
	{ code = "Vietnamese", name = "Tiếng Việt" },
	{ code = "Indonesian", name = "Bahasa Indonesia" },
	{ code = "Filipino", name = "Filipino" },
}

local tbl2 = {}

for _, sovereignHubLanguageOption in ipairs(sovereignHubLanguageOptions) do
	tbl2[sovereignHubLanguageOption.code] = sovereignHubLanguageOption.name
end

local tbl3 = {
	Spanish = {
		["Select the experience you want to use."] = "Selecciona la experiencia que quieres usar.",
		["Enter your access key to continue"] = "Introduce tu clave de acceso para continuar",
		["Enter your access key to continue to Sovereign Hub."] = "Introduce tu clave de acceso para continuar a Sovereign Hub.",
		["Sovereign Hub Access"] = "Clave de acceso",
		["Launch"] = "Obtener clave",
		["Click Here to Get a Key"] = "Haz clic aquí para obtener una clave",
		["Join Discord"] = "Únete a Discord",
		Language = "Idioma",
		Close = "Cerrar",
		["Key accepted"] = "Clave aceptada",
		["Connection unavailable. Try again."] = "Conexión no disponible. Inténtalo de nuevo.",
		["Unable to verify key. Try again."] = "No se pudo verificar la clave. Inténtalo de nuevo.",
		["Loading Sovereign Hub..."] = "Preparando Sovereign Hub...",
		["Clipboard unavailable"] = "Portapapeles no disponible",
		["<b>NEED ACCESS?</b>\nClick the key button to generate your own access key."] = "<b>¿NECESITAS ACCESO?</b>\nPulsa el botón de clave para generar tu propia clave.",
		["SOVEREIGN HUB"] = "CLAVE DE ACCESO",
		["Continue"] = "Validar clave",
		["Get-key link copied!"] = "¡Enlace de clave copiado!",
		["Discord invite copied!"] = "¡Invitación de Discord copiada!",
		["Please enter a key"] = "Introduce una clave",
		["Beta key retired - use Get a Key below"] = "La clave beta fue retirada; obtén una nueva abajo",
		["Checking..."] = "Comprobando...",
		["Unavailable"] = "Clave no válida",
		Home = "Inicio",
		Movement = "Movimiento",
		Glitches = "Glitches",
		Aim = "Apuntado",
		Visuals = "Visuales",
		Combat = "Combate",
		Blacklist = "Lista negra",
		Exclude = "Excluir",
		Misc = "Varios",
		Macro = "Macro",
		Mobile = "Móvil",
		["Skin Changer"] = "Cambiador de aspectos",
		Shop = "Tienda",
		Client = "Cliente",
		Key = "Clave",
		Appearance = "Apariencia",
		Settings = "Ajustes",
		Keybinds = "Teclas",
		CONTROLS = "CONTROLES",
		ACTIONS = "ACCIONES",
		VISIBILITY = "VISIBILIDAD",
		MODE = "MODO",
		RESET = "RESTABLECER",
		["Enable Skin Changer"] = "Activar cambiador de aspectos",
		["RGB Cycle"] = "Ciclo RGB",
		["Preset Color"] = "Color predefinido",
		["Indicator Color"] = "Color del indicador",
		["Button Color"] = "Color del botón",
		Save = "Guardar",
		Cancel = "Cancelar",
		["Pick a Color"] = "Elegir un color",
		["Selected: "] = "Seleccionado: ",
	},
	Portuguese = {
		["Select the experience you want to use."] = "Selecione a experiência que deseja usar.",
		["Enter your access key to continue"] = "Insira sua chave de acesso para continuar",
		["Enter your access key to continue to Sovereign Hub."] = "Digite sua chave de acesso para continuar no Sovereign Hub.",
		["Sovereign Hub Access"] = "Chave de acesso",
		["Launch"] = "Obter chave",
		["Click Here to Get a Key"] = "Clique aqui para obter uma chave",
		["Join Discord"] = "Entrar no Discord",
		Language = "Idioma",
		Close = "Fechar",
		["Key accepted"] = "Chave aceita",
		["Connection unavailable. Try again."] = "Conexão indisponível. Tente novamente.",
		["Unable to verify key. Try again."] = "Não foi possível verificar a chave. Tente novamente.",
		["Loading Sovereign Hub..."] = "Preparando Sovereign Hub...",
		["Clipboard unavailable"] = "Área de transferência indisponível",
		["<b>NEED ACCESS?</b>\nClick the key button to generate your own access key."] = "<b>PRECISA DE ACESSO?</b>\nClique no botão de chave para gerar sua própria chave.",
		["SOVEREIGN HUB"] = "CHAVE DE ACESSO",
		["Continue"] = "Validar chave",
		["Get-key link copied!"] = "Link da chave copiado!",
		["Discord invite copied!"] = "Convite do Discord copiado!",
		["Please enter a key"] = "Insira uma chave",
		["Beta key retired - use Get a Key below"] = "A chave beta foi removida; obtenha uma nova abaixo",
		["Checking..."] = "Verificando...",
		["Unavailable"] = "Chave inválida",
		Home = "Início",
		Movement = "Movimento",
		Glitches = "Glitches",
		Aim = "Mira",
		Visuals = "Visuais",
		Combat = "Combate",
		Blacklist = "Lista negra",
		Exclude = "Excluir",
		Misc = "Diversos",
		Macro = "Macro",
		Mobile = "Celular",
		["Skin Changer"] = "Alterador de skins",
		Shop = "Loja",
		Client = "Cliente",
		Key = "Chave",
		Appearance = "Aparência",
		Settings = "Configurações",
		Keybinds = "Teclas",
		CONTROLS = "CONTROLES",
		ACTIONS = "AÇÕES",
		VISIBILITY = "VISIBILIDADE",
		MODE = "MODO",
		RESET = "REDEFINIR",
		["Enable Skin Changer"] = "Ativar alterador de skins",
		["RGB Cycle"] = "Ciclo RGB",
		["Preset Color"] = "Cor predefinida",
		["Indicator Color"] = "Cor do indicador",
		["Button Color"] = "Cor do botão",
		Save = "Salvar",
		Cancel = "Cancelar",
		["Pick a Color"] = "Escolha uma cor",
		["Selected: "] = "Selecionado: ",
	},
	French = {
		["Select the experience you want to use."] = "Sélectionnez l’expérience que vous souhaitez utiliser.",
		["Enter your access key to continue"] = "Entrez votre clé d’accès pour continuer",
		["Enter your access key to continue to Sovereign Hub."] = "Entrez votre clé d’accès pour continuer vers Sovereign Hub.",
		["Sovereign Hub Access"] = "Clé d’accès",
		["Launch"] = "Obtenir une clé",
		["Click Here to Get a Key"] = "Cliquez ici pour obtenir une clé",
		["Join Discord"] = "Rejoindre Discord",
		Language = "Langue",
		Close = "Fermer",
		["Key accepted"] = "Clé acceptée",
		["Connection unavailable. Try again."] = "Connexion indisponible. Réessayez.",
		["Unable to verify key. Try again."] = "Impossible de vérifier la clé. Réessayez.",
		["Loading Sovereign Hub..."] = "Préparation de Sovereign Hub...",
		["Clipboard unavailable"] = "Presse-papiers indisponible",
		["<b>NEED ACCESS?</b>\nClick the key button to generate your own access key."] = "<b>BESOIN D'ACCÈS ?</b>\nCliquez sur le bouton de clé pour générer votre clé.",
		["SOVEREIGN HUB"] = "CLÉ D'ACCÈS",
		["Continue"] = "Valider la clé",
		["Get-key link copied!"] = "Lien de clé copié !",
		["Discord invite copied!"] = "Invitation Discord copiée !",
		["Please enter a key"] = "Veuillez entrer une clé",
		["Beta key retired - use Get a Key below"] = "La clé bêta a été retirée ; obtenez-en une nouvelle ci-dessous",
		["Checking..."] = "Vérification...",
		["Unavailable"] = "Clé invalide",
		Home = "Accueil",
		Movement = "Mouvement",
		Glitches = "Glitches",
		Aim = "Visée",
		Visuals = "Visuels",
		Combat = "Combat",
		Blacklist = "Liste noire",
		Exclude = "Exclure",
		Misc = "Divers",
		Macro = "Macro",
		Mobile = "Mobile",
		["Skin Changer"] = "Changeur d'effets",
		Shop = "Boutique",
		Client = "Client",
		Key = "Clé",
		Appearance = "Apparence",
		Settings = "Paramètres",
		Keybinds = "Raccourcis",
		CONTROLS = "COMMANDES",
		ACTIONS = "ACTIONS",
		VISIBILITY = "VISIBILITÉ",
		MODE = "MODE",
		RESET = "RÉINITIALISER",
		["Enable Skin Changer"] = "Activer le changeur d'effets",
		["RGB Cycle"] = "Cycle RGB",
		["Preset Color"] = "Couleur prédéfinie",
		["Indicator Color"] = "Couleur de l'indicateur",
		["Button Color"] = "Couleur du bouton",
		Save = "Enregistrer",
		Cancel = "Annuler",
		["Pick a Color"] = "Choisir une couleur",
		["Selected: "] = "Sélectionné : ",
	},
	Vietnamese = {
		["Select the experience you want to use."] = "Chọn trải nghiệm bạn muốn sử dụng.",
		["Enter your access key to continue"] = "Nhập key truy cập để tiếp tục",
		["Enter your access key to continue to Sovereign Hub."] = "Nhập mã truy cập để tiếp tục đến Sovereign Hub.",
		["Sovereign Hub Access"] = "Key truy cập",
		["Launch"] = "Lấy key",
		["Click Here to Get a Key"] = "Nhấn vào đây để lấy key",
		["Join Discord"] = "Tham gia Discord",
		Language = "Ngôn ngữ",
		Close = "Đóng",
		["Key accepted"] = "Key được chấp nhận",
		["Connection unavailable. Try again."] = "Không thể kết nối. Hãy thử lại.",
		["Unable to verify key. Try again."] = "Không thể xác minh key. Hãy thử lại.",
		["Loading Sovereign Hub..."] = "Đang chuẩn bị Sovereign Hub...",
		["Clipboard unavailable"] = "Không có bộ nhớ tạm",
		["<b>NEED ACCESS?</b>\nClick the key button to generate your own access key."] = "<b>CẦN QUYỀN TRUY CẬP?</b>\nNhấn nút key để tạo key truy cập của bạn.",
		["SOVEREIGN HUB"] = "KEY TRUY CẬP",
		["Continue"] = "Xác thực key",
		["Get-key link copied!"] = "Đã sao chép liên kết lấy key!",
		["Discord invite copied!"] = "Đã sao chép lời mời Discord!",
		["Please enter a key"] = "Vui lòng nhập key",
		["Beta key retired - use Get a Key below"] = "Key beta đã bị gỡ; hãy lấy key mới bên dưới",
		["Checking..."] = "Đang kiểm tra...",
		["Unavailable"] = "Key không hợp lệ",
		Home = "Trang chủ",
		Movement = "Di chuyển",
		Glitches = "Kỹ thuật",
		Aim = "Ngắm",
		Visuals = "Hiển thị",
		Combat = "Chiến đấu",
		Blacklist = "Danh sách đen",
		Exclude = "Loại trừ",
		Misc = "Khác",
		Macro = "Macro",
		Mobile = "Di động",
		["Skin Changer"] = "Đổi hiệu ứng",
		Shop = "Cửa hàng",
		Client = "Máy khách",
		Key = "Key",
		Appearance = "Giao diện",
		Settings = "Cài đặt",
		Keybinds = "Phím tắt",
		CONTROLS = "ĐIỀU KHIỂN",
		ACTIONS = "THAO TÁC",
		VISIBILITY = "HIỂN THỊ",
		MODE = "CHẾ ĐỘ",
		RESET = "ĐẶT LẠI",
		["Enable Skin Changer"] = "Bật đổi hiệu ứng",
		["RGB Cycle"] = "Chu kỳ RGB",
		["Preset Color"] = "Màu có sẵn",
		["Indicator Color"] = "Màu chỉ báo",
		["Button Color"] = "Màu nút",
		Save = "Lưu",
		Cancel = "Hủy",
		["Pick a Color"] = "Chọn màu",
		["Selected: "] = "Đã chọn: ",
	},
	Indonesian = {
		["Select the experience you want to use."] = "Pilih pengalaman yang ingin Anda gunakan.",
		["Enter your access key to continue"] = "Masukkan key akses untuk melanjutkan",
		["Enter your access key to continue to Sovereign Hub."] = "Masukkan kunci akses untuk melanjutkan ke Sovereign Hub.",
		["Sovereign Hub Access"] = "Key akses",
		["Launch"] = "Dapatkan key",
		["Click Here to Get a Key"] = "Klik di sini untuk mendapatkan key",
		["Join Discord"] = "Gabung Discord",
		Language = "Bahasa",
		Close = "Tutup",
		["Key accepted"] = "Key diterima",
		["Connection unavailable. Try again."] = "Koneksi tidak tersedia. Coba lagi.",
		["Unable to verify key. Try again."] = "Key tidak dapat diverifikasi. Coba lagi.",
		["Loading Sovereign Hub..."] = "Menyiapkan Sovereign Hub...",
		["Clipboard unavailable"] = "Papan klip tidak tersedia",
		["<b>NEED ACCESS?</b>\nClick the key button to generate your own access key."] = "<b>BUTUH AKSES?</b>\nKlik tombol key untuk membuat key akses milikmu.",
		["SOVEREIGN HUB"] = "KEY AKSES",
		["Continue"] = "Validasi key",
		["Get-key link copied!"] = "Tautan key disalin!",
		["Discord invite copied!"] = "Undangan Discord disalin!",
		["Please enter a key"] = "Silakan masukkan key",
		["Beta key retired - use Get a Key below"] = "Key beta dihentikan; dapatkan key baru di bawah",
		["Checking..."] = "Memeriksa...",
		["Unavailable"] = "Key tidak valid",
		Home = "Beranda",
		Movement = "Gerakan",
		Glitches = "Glitch",
		Aim = "Bidikan",
		Visuals = "Visual",
		Combat = "Pertarungan",
		Blacklist = "Daftar hitam",
		Exclude = "Kecualikan",
		Misc = "Lainnya",
		Macro = "Makro",
		Mobile = "Seluler",
		["Skin Changer"] = "Pengubah efek",
		Shop = "Toko",
		Client = "Klien",
		Key = "Key",
		Appearance = "Tampilan",
		Settings = "Pengaturan",
		Keybinds = "Tombol pintas",
		CONTROLS = "KONTROL",
		ACTIONS = "TINDAKAN",
		VISIBILITY = "VISIBILITAS",
		MODE = "MODE",
		RESET = "ATUR ULANG",
		["Enable Skin Changer"] = "Aktifkan pengubah efek",
		["RGB Cycle"] = "Siklus RGB",
		["Preset Color"] = "Warna preset",
		["Indicator Color"] = "Warna indikator",
		["Button Color"] = "Warna tombol",
		Save = "Simpan",
		Cancel = "Batal",
		["Pick a Color"] = "Pilih warna",
		["Selected: "] = "Dipilih: ",
	},
	Filipino = {
		["Select the experience you want to use."] = "Piliin ang experience na gusto mong gamitin.",
		["Enter your access key to continue"] = "Ilagay ang access key mo upang magpatuloy",
		["Enter your access key to continue to Sovereign Hub."] = "Ilagay ang iyong access key para magpatuloy sa Sovereign Hub.",
		["Sovereign Hub Access"] = "Sovereign Hub Access",
		["Launch"] = "Kumuha ng key",
		["Click Here to Get a Key"] = "Mag-click dito para kumuha ng key",
		["Join Discord"] = "Sumali sa Discord",
		Language = "Wika",
		Close = "Isara",
		["Key accepted"] = "Tinanggap ang key",
		["Connection unavailable. Try again."] = "Walang koneksyon. Subukan muli.",
		["Unable to verify key. Try again."] = "Hindi ma-verify ang key. Subukan muli.",
		["Loading Sovereign Hub..."] = "Inihahanda ang Sovereign Hub...",
		["Clipboard unavailable"] = "Hindi available ang clipboard",
		["<b>NEED ACCESS?</b>\nClick the key button to generate your own access key."] = "<b>KAILANGAN NG ACCESS?</b>\nI-click ang key button para gumawa ng sarili mong access key.",
		["SOVEREIGN HUB"] = "SOVEREIGN HUB",
		["Continue"] = "I-validate ang key",
		["Get-key link copied!"] = "Nakopya ang link para sa key!",
		["Discord invite copied!"] = "Nakopya ang Discord invite!",
		["Please enter a key"] = "Mangyaring maglagay ng key",
		["Beta key retired - use Get a Key below"] = "Itinigil na ang beta key; kumuha ng bagong key sa ibaba",
		["Checking..."] = "Sinusuri...",
		["Unavailable"] = "Hindi wastong key",
		Home = "Home",
		Movement = "Paggalaw",
		Glitches = "Glitches",
		Aim = "Pagpuntirya",
		Visuals = "Mga Visual",
		Combat = "Labanan",
		Blacklist = "Blacklist",
		Exclude = "Ibukod",
		Misc = "Iba pa",
		Macro = "Macro",
		Mobile = "Mobile",
		["Skin Changer"] = "Skin Changer",
		Shop = "Tindahan",
		Client = "Client",
		Key = "Key",
		Appearance = "Hitsura",
		Settings = "Mga Setting",
		Keybinds = "Mga Keybind",
		CONTROLS = "MGA CONTROL",
		ACTIONS = "MGA AKSYON",
		VISIBILITY = "PAGKAKAKITA",
		MODE = "MODE",
		RESET = "I-RESET",
		["Enable Skin Changer"] = "I-enable ang Skin Changer",
		["RGB Cycle"] = "RGB Cycle",
		["Preset Color"] = "Preset na Kulay",
		["Indicator Color"] = "Kulay ng Indicator",
		["Button Color"] = "Kulay ng Button",
		Save = "I-save",
		Cancel = "Kanselahin",
		["Pick a Color"] = "Pumili ng Kulay",
		["Selected: "] = "Napili: ",
	},
}

for k, value3 in pairs({
	Spanish = {
		["Choose Your Sovereign Hub Experience"] = "Elige tu experiencia Sovereign Hub",
		["Select the experience that fits how you play."] = "Selecciona la experiencia que mejor se adapte a tu forma de jugar.",
		["Full Experience"] = "Experiencia Completa",
		["Core Experience"] = "Experiencia Esencial",
		["The complete Sovereign Hub experience."] = "La experiencia completa de Sovereign Hub.",
		["A simple, focused Sovereign Hub experience."] = "Una experiencia Sovereign Hub sencilla y enfocada.",
		["Classic Experience"] = "Experiencia clásica",
		["Essential Features"] = "Funciones esenciales",
		["Streamlined Interface"] = "Interfaz optimizada",
		["Faster Setup"] = "Configuración más rápida",
		["Launch Full"] = "Iniciar Full",
		["Launch Core"] = "Iniciar Core",
		["Choose Your Experience"] = "Elige tu experiencia",
		["You can change this again later."] = "Podrás cambiar esto más adelante.",
		Lite = "Lite",
		Full = "Full",
		Recommended = "Recomendado",
		["Core Features"] = "Funciones principales",
		["Simpler Interface"] = "Interfaz más sencilla",
		["Easier to Use"] = "Más fácil de usar",
		["All Features"] = "Todas las funciones",
		["Advanced Controls"] = "Controles avanzados",
		["Full Customization"] = "Personalización completa",
		["Load Lite"] = "Cargar Lite",
		["Load Full"] = "Cargar Full",
		["Remember and skip this screen next time"] = "Recordar y omitir esta pantalla la próxima vez",
		["Choose how you want Sovereign Hub to run. You can change this later in Settings."] = "Elige cómo quieres usar Sovereign Hub. Puedes cambiarlo más tarde en Ajustes.",
		["Existing / Classic Experience"] = "Experiencia existente / clásica",
		["Preparing Lite..."] = "Preparando Lite...",
		["Preparing Full..."] = "Preparando Full...",
		["Preference could not be saved"] = "No se pudo guardar la preferencia",
		["Verifying key..."] = "Verificando clave...",
		["Starting %s..."] = "Iniciando %s...",
		["Cleanup could not be verified. Re-execute Sovereign Hub to continue."] = "No se pudo verificar la limpieza. Vuelve a ejecutar Sovereign Hub para continuar.",
	},
	Portuguese = {
		["Choose Your Sovereign Hub Experience"] = "Escolha sua experiência Sovereign Hub",
		["Select the experience that fits how you play."] = "Selecione a experiência que combina com seu jeito de jogar.",
		["Full Experience"] = "Experiência Completa",
		["Core Experience"] = "Experiência Essencial",
		["The complete Sovereign Hub experience."] = "A experiência Sovereign Hub completa.",
		["A simple, focused Sovereign Hub experience."] = "Uma experiência Sovereign Hub simples e focada.",
		["Classic Experience"] = "Experiência clássica",
		["Essential Features"] = "Recursos essenciais",
		["Streamlined Interface"] = "Interface otimizada",
		["Faster Setup"] = "Configuração mais rápida",
		["Launch Full"] = "Iniciar Full",
		["Launch Core"] = "Iniciar Core",
		["Choose Your Experience"] = "Escolha sua experiência",
		["You can change this again later."] = "Você poderá alterar isso mais tarde.",
		Lite = "Lite",
		Full = "Full",
		Recommended = "Recomendado",
		["Core Features"] = "Recursos principais",
		["Simpler Interface"] = "Interface mais simples",
		["Easier to Use"] = "Mais fácil de usar",
		["All Features"] = "Todos os recursos",
		["Advanced Controls"] = "Controles avançados",
		["Full Customization"] = "Personalização completa",
		["Load Lite"] = "Carregar Lite",
		["Load Full"] = "Carregar Full",
		["Remember and skip this screen next time"] = "Lembrar e pular esta tela na próxima vez",
		["Choose how you want Sovereign Hub to run. You can change this later in Settings."] = "Escolha como deseja usar o Sovereign Hub. Você pode alterar isso depois em Configurações.",
		["Existing / Classic Experience"] = "Experiência existente / clássica",
		["Preparing Lite..."] = "Preparando Lite...",
		["Preparing Full..."] = "Preparando Full...",
		["Preference could not be saved"] = "Não foi possível salvar a preferência",
		["Verifying key..."] = "Verificando a chave...",
		["Starting %s..."] = "Iniciando %s...",
		["Cleanup could not be verified. Re-execute Sovereign Hub to continue."] = "Não foi possível verificar a limpeza. Execute o Sovereign Hub novamente para continuar.",
	},
	French = {
		["Choose Your Sovereign Hub Experience"] = "Choisissez votre expérience Sovereign Hub",
		["Select the experience that fits how you play."] = "Sélectionnez l’expérience adaptée à votre façon de jouer.",
		["Full Experience"] = "Expérience Complète",
		["Core Experience"] = "Expérience Essentielle",
		["The complete Sovereign Hub experience."] = "L’expérience Sovereign Hub complète.",
		["A simple, focused Sovereign Hub experience."] = "Une expérience Sovereign Hub simple et ciblée.",
		["Classic Experience"] = "Expérience classique",
		["Essential Features"] = "Fonctions essentielles",
		["Streamlined Interface"] = "Interface optimisée",
		["Faster Setup"] = "Configuration plus rapide",
		["Launch Full"] = "Lancer Full",
		["Launch Core"] = "Lancer Core",
		["Choose Your Experience"] = "Choisissez votre expérience",
		["You can change this again later."] = "Vous pourrez modifier ce choix plus tard.",
		Lite = "Lite",
		Full = "Full",
		Recommended = "Recommandé",
		["Core Features"] = "Fonctions essentielles",
		["Simpler Interface"] = "Interface simplifiée",
		["Easier to Use"] = "Plus facile à utiliser",
		["All Features"] = "Toutes les fonctions",
		["Advanced Controls"] = "Contrôles avancés",
		["Full Customization"] = "Personnalisation complète",
		["Load Lite"] = "Charger Lite",
		["Load Full"] = "Charger Full",
		["Remember and skip this screen next time"] = "Mémoriser et ignorer cet écran la prochaine fois",
		["Choose how you want Sovereign Hub to run. You can change this later in Settings."] = "Choisissez comment utiliser Sovereign Hub. Vous pourrez modifier ce choix plus tard dans les paramètres.",
		["Existing / Classic Experience"] = "Expérience existante / classique",
		["Preparing Lite..."] = "Préparation de Lite...",
		["Preparing Full..."] = "Préparation de Full...",
		["Preference could not be saved"] = "La préférence n'a pas pu être enregistrée",
		["Verifying key..."] = "Vérification de la clé...",
		["Starting %s..."] = "Démarrage de %s...",
		["Cleanup could not be verified. Re-execute Sovereign Hub to continue."] = "Le nettoyage n'a pas pu être vérifié. Relancez Sovereign Hub pour continuer.",
	},
	Vietnamese = {
		["Choose Your Sovereign Hub Experience"] = "Chọn trải nghiệm Sovereign Hub của bạn",
		["Select the experience that fits how you play."] = "Chọn trải nghiệm phù hợp với cách chơi của bạn.",
		["Full Experience"] = "Trải Nghiệm Đầy Đủ",
		["Core Experience"] = "Trải Nghiệm Cốt Lõi",
		["The complete Sovereign Hub experience."] = "Trải nghiệm Sovereign Hub hoàn chỉnh.",
		["A simple, focused Sovereign Hub experience."] = "Trải nghiệm Sovereign Hub đơn giản và tập trung.",
		["Classic Experience"] = "Trải nghiệm cổ điển",
		["Essential Features"] = "Tính năng thiết yếu",
		["Streamlined Interface"] = "Giao diện tinh gọn",
		["Faster Setup"] = "Thiết lập nhanh hơn",
		["Launch Full"] = "Khởi chạy Full",
		["Launch Core"] = "Khởi chạy Core",
		["Choose Your Experience"] = "Chọn trải nghiệm của bạn",
		["You can change this again later."] = "Bạn có thể đổi lựa chọn này sau.",
		Lite = "Lite",
		Full = "Full",
		Recommended = "Đề xuất",
		["Core Features"] = "Tính năng cốt lõi",
		["Simpler Interface"] = "Giao diện đơn giản hơn",
		["Easier to Use"] = "Dễ sử dụng hơn",
		["All Features"] = "Tất cả tính năng",
		["Advanced Controls"] = "Điều khiển nâng cao",
		["Full Customization"] = "Tùy chỉnh đầy đủ",
		["Load Lite"] = "Tải Lite",
		["Load Full"] = "Tải Full",
		["Remember and skip this screen next time"] = "Ghi nhớ và bỏ qua màn hình này lần sau",
		["Choose how you want Sovereign Hub to run. You can change this later in Settings."] = "Chọn cách bạn muốn Sovereign Hub hoạt động. Bạn có thể thay đổi sau trong Cài đặt.",
		["Existing / Classic Experience"] = "Trải nghiệm hiện có / cổ điển",
		["Preparing Lite..."] = "Đang chuẩn bị Lite...",
		["Preparing Full..."] = "Đang chuẩn bị Full...",
		["Preference could not be saved"] = "Không thể lưu tùy chọn",
		["Verifying key..."] = "Đang xác minh khóa...",
		["Starting %s..."] = "Đang khởi động %s...",
		["Cleanup could not be verified. Re-execute Sovereign Hub to continue."] = "Không thể xác minh việc dọn dẹp. Hãy chạy lại Sovereign Hub để tiếp tục.",
	},
	Indonesian = {
		["Choose Your Sovereign Hub Experience"] = "Pilih pengalaman Sovereign Hub Anda",
		["Select the experience that fits how you play."] = "Pilih pengalaman yang sesuai dengan cara bermain Anda.",
		["Full Experience"] = "Pengalaman Lengkap",
		["Core Experience"] = "Pengalaman Inti",
		["The complete Sovereign Hub experience."] = "Pengalaman Sovereign Hub lengkap.",
		["A simple, focused Sovereign Hub experience."] = "Pengalaman Sovereign Hub yang sederhana dan terfokus.",
		["Classic Experience"] = "Pengalaman klasik",
		["Essential Features"] = "Fitur penting",
		["Streamlined Interface"] = "Antarmuka ringkas",
		["Faster Setup"] = "Pengaturan lebih cepat",
		["Launch Full"] = "Jalankan Full",
		["Launch Core"] = "Jalankan Core",
		["Choose Your Experience"] = "Pilih pengalaman Anda",
		["You can change this again later."] = "Anda dapat mengubah pilihan ini nanti.",
		Lite = "Lite",
		Full = "Full",
		Recommended = "Disarankan",
		["Core Features"] = "Fitur inti",
		["Simpler Interface"] = "Antarmuka lebih sederhana",
		["Easier to Use"] = "Lebih mudah digunakan",
		["All Features"] = "Semua fitur",
		["Advanced Controls"] = "Kontrol lanjutan",
		["Full Customization"] = "Kustomisasi penuh",
		["Load Lite"] = "Muat Lite",
		["Load Full"] = "Muat Full",
		["Remember and skip this screen next time"] = "Ingat dan lewati layar ini lain kali",
		["Choose how you want Sovereign Hub to run. You can change this later in Settings."] = "Pilih cara Sovereign Hub berjalan. Anda dapat mengubahnya nanti di Pengaturan.",
		["Existing / Classic Experience"] = "Pengalaman lama / klasik",
		["Preparing Lite..."] = "Menyiapkan Lite...",
		["Preparing Full..."] = "Menyiapkan Full...",
		["Preference could not be saved"] = "Preferensi tidak dapat disimpan",
		["Verifying key..."] = "Memverifikasi kunci...",
		["Starting %s..."] = "Memulai %s...",
		["Cleanup could not be verified. Re-execute Sovereign Hub to continue."] = "Pembersihan tidak dapat diverifikasi. Jalankan ulang Sovereign Hub untuk melanjutkan.",
	},
	Filipino = {
		["Choose Your Sovereign Hub Experience"] = "Piliin ang iyong Sovereign Hub experience",
		["Select the experience that fits how you play."] = "Piliin ang experience na akma sa paraan ng paglalaro mo.",
		["Full Experience"] = "Full Experience",
		["Core Experience"] = "Core Experience",
		["The complete Sovereign Hub experience."] = "Ang kumpletong Sovereign Hub experience.",
		["A simple, focused Sovereign Hub experience."] = "Isang simple at focused na Sovereign Hub experience.",
		["Classic Experience"] = "Classic experience",
		["Essential Features"] = "Mahahalagang feature",
		["Streamlined Interface"] = "Mas maayos na interface",
		["Faster Setup"] = "Mas mabilis na setup",
		["Launch Full"] = "Buksan ang Full",
		["Launch Core"] = "Buksan ang Core",
		["Choose Your Experience"] = "Piliin ang iyong experience",
		["You can change this again later."] = "Maaari mo itong baguhin sa susunod.",
		Lite = "Lite",
		Full = "Full",
		Recommended = "Inirerekomenda",
		["Core Features"] = "Mga pangunahing feature",
		["Simpler Interface"] = "Mas simpleng interface",
		["Easier to Use"] = "Mas madaling gamitin",
		["All Features"] = "Lahat ng feature",
		["Advanced Controls"] = "Advanced na controls",
		["Full Customization"] = "Buong customization",
		["Load Lite"] = "I-load ang Lite",
		["Load Full"] = "I-load ang Full",
		["Remember and skip this screen next time"] = "Tandaan at laktawan ang screen na ito sa susunod",
		["Choose how you want Sovereign Hub to run. You can change this later in Settings."] = "Piliin kung paano tatakbo ang Sovereign Hub. Maaari mo itong baguhin sa Settings.",
		["Existing / Classic Experience"] = "Kasalukuyan / classic na experience",
		["Preparing Lite..."] = "Inihahanda ang Lite...",
		["Preparing Full..."] = "Inihahanda ang Full...",
		["Preference could not be saved"] = "Hindi na-save ang preference",
		["Verifying key..."] = "Vine-verify ang key...",
		["Starting %s..."] = "Sinisimulan ang %s...",
		["Cleanup could not be verified. Re-execute Sovereign Hub to continue."] = "Hindi ma-verify ang cleanup. I-execute ulit ang Sovereign Hub para magpatuloy.",
	},
}) do
	local tbl4 = tbl3[k] or {}
	tbl3[k] = tbl4

	for k2, value4 in pairs(value3) do
		tbl3[k][k2] = value4
	end
end

for k, value5 in pairs({
	Spanish = {
		LANGUAGE = "IDIOMA",
		["Select Language"] = "Seleccionar idioma",
		Gold = "Dorado",
		Red = "Rojo",
		Green = "Verde",
		Cyan = "Cian",
		White = "Blanco",
		Magenta = "Magenta",
		Pink = "Rosa",
		Purple = "Morado",
		Blue = "Azul",
		Black = "Negro",
		Midnight = "Medianoche",
		["Custom RGB"] = "RGB personalizado",
		["Top Right"] = "Arriba derecha",
		["Top Left"] = "Arriba izquierda",
		["Bottom Right"] = "Abajo derecha",
		["Bottom Left"] = "Abajo izquierda",
		Line = "Línea",
		None = "Ninguno",
		Tap = "Tocar",
		Hold = "Mantener",
		On = "Activado",
		Off = "Desactivado",
		["Jumps After Skill"] = "Saltos después de la habilidad",
		Jump = "Salto",
		Jumps = "Saltos",
		["Skill Aimbot"] = "Aimbot de habilidades",
		["Soru Aimbot"] = "Aimbot de Soru",
		["Auto Prediction"] = "Predicción automática",
		["Safe Zone Filter"] = "Filtro de zona segura",
		["Target Mode"] = "Modo de objetivo",
		["Target Priority"] = "Prioridad de objetivo",
		["Target Switch Delay"] = "Retraso de cambio de objetivo",
		["360° Targeting"] = "Objetivo 360°",
		["Skill CamLock"] = "CamLock de habilidades",
		["Ability Range Check"] = "Comprobación de alcance",
		["Show FOV Circle"] = "Mostrar círculo FOV",
		["ESP Enabled"] = "Activar ESP",
		["Speed Boost"] = "Aumento de velocidad",
		["Dash Boost"] = "Aumento de dash",
		["Jump Boost"] = "Aumento de salto",
		["Walk on Water"] = "Caminar sobre agua",
		["Walk on Lava"] = "Caminar sobre lava",
		["Auto V3"] = "V3 automático",
		["Smart V3"] = "V3 inteligente",
		["Auto V4"] = "V4 automático",
		["Smart V4"] = "V4 inteligente",
		["Normal Safe Mode"] = "Modo seguro normal",
		["Disable Notifications"] = "Desactivar notificaciones",
		["Streamer Mode"] = "Modo streamer",
		["Hide Control Fruit Effects"] = "Ocultar efectos de la fruta Control",
		["Locally hides Control's room visuals and pauses its heavy bubble animation"] = "Oculta localmente los efectos de la sala de Control y pausa la pesada animación de la burbuja",
	},
	Portuguese = {
		LANGUAGE = "IDIOMA",
		["Select Language"] = "Selecionar idioma",
		Gold = "Dourado",
		Red = "Vermelho",
		Green = "Verde",
		Cyan = "Ciano",
		White = "Branco",
		Magenta = "Magenta",
		Pink = "Rosa",
		Purple = "Roxo",
		Blue = "Azul",
		Black = "Preto",
		Midnight = "Meia-noite",
		["Custom RGB"] = "RGB personalizado",
		["Top Right"] = "Superior direito",
		["Top Left"] = "Superior esquerdo",
		["Bottom Right"] = "Inferior direito",
		["Bottom Left"] = "Inferior esquerdo",
		Line = "Linha",
		None = "Nenhum",
		Tap = "Toque",
		Hold = "Segurar",
		On = "Ligado",
		Off = "Desligado",
		["Jumps After Skill"] = "Saltos após a habilidade",
		Jump = "Salto",
		Jumps = "Saltos",
		["Skill Aimbot"] = "Aimbot de habilidades",
		["Soru Aimbot"] = "Aimbot de Soru",
		["Auto Prediction"] = "Predição automática",
		["Safe Zone Filter"] = "Filtro de zona segura",
		["Target Mode"] = "Modo de alvo",
		["Target Priority"] = "Prioridade do alvo",
		["Target Switch Delay"] = "Atraso para trocar alvo",
		["360° Targeting"] = "Alvo 360°",
		["Skill CamLock"] = "CamLock de habilidades",
		["Ability Range Check"] = "Verificação de alcance",
		["Show FOV Circle"] = "Mostrar círculo FOV",
		["ESP Enabled"] = "Ativar ESP",
		["Speed Boost"] = "Aumento de velocidade",
		["Dash Boost"] = "Aumento de dash",
		["Jump Boost"] = "Aumento de pulo",
		["Walk on Water"] = "Andar na água",
		["Walk on Lava"] = "Andar na lava",
		["Auto V3"] = "V3 automático",
		["Smart V3"] = "V3 inteligente",
		["Auto V4"] = "V4 automático",
		["Smart V4"] = "V4 inteligente",
		["Normal Safe Mode"] = "Modo seguro normal",
		["Disable Notifications"] = "Desativar notificações",
		["Streamer Mode"] = "Modo streamer",
		["Hide Control Fruit Effects"] = "Ocultar efeitos da fruta Control",
		["Locally hides Control's room visuals and pauses its heavy bubble animation"] = "Oculta localmente os efeitos da sala do Control e pausa a animação pesada da bolha",
	},
	French = {
		LANGUAGE = "LANGUE",
		["Select Language"] = "Choisir la langue",
		Gold = "Or",
		Red = "Rouge",
		Green = "Vert",
		Cyan = "Cyan",
		White = "Blanc",
		Magenta = "Magenta",
		Pink = "Rose",
		Purple = "Violet",
		Blue = "Bleu",
		Black = "Noir",
		Midnight = "Minuit",
		["Custom RGB"] = "RGB personnalisé",
		["Top Right"] = "En haut à droite",
		["Top Left"] = "En haut à gauche",
		["Bottom Right"] = "En bas à droite",
		["Bottom Left"] = "En bas à gauche",
		Line = "Ligne",
		None = "Aucun",
		Tap = "Appui",
		Hold = "Maintenir",
		On = "Activé",
		Off = "Désactivé",
		["Jumps After Skill"] = "Sauts après la compétence",
		Jump = "Saut",
		Jumps = "Sauts",
		["Skill Aimbot"] = "Aimbot de compétences",
		["Soru Aimbot"] = "Aimbot de Soru",
		["Auto Prediction"] = "Prédiction automatique",
		["Safe Zone Filter"] = "Filtre de zone sûre",
		["Target Mode"] = "Mode de ciblage",
		["Target Priority"] = "Priorité de cible",
		["Target Switch Delay"] = "Délai de changement de cible",
		["360° Targeting"] = "Ciblage à 360°",
		["Skill CamLock"] = "CamLock des compétences",
		["Ability Range Check"] = "Vérification de portée",
		["Show FOV Circle"] = "Afficher le cercle FOV",
		["ESP Enabled"] = "Activer l'ESP",
		["Speed Boost"] = "Boost de vitesse",
		["Dash Boost"] = "Boost de dash",
		["Jump Boost"] = "Boost de saut",
		["Walk on Water"] = "Marcher sur l'eau",
		["Walk on Lava"] = "Marcher sur la lave",
		["Auto V3"] = "V3 automatique",
		["Smart V3"] = "V3 intelligent",
		["Auto V4"] = "V4 automatique",
		["Smart V4"] = "V4 intelligent",
		["Normal Safe Mode"] = "Mode sécurisé normal",
		["Disable Notifications"] = "Désactiver les notifications",
		["Streamer Mode"] = "Mode streamer",
		["Hide Control Fruit Effects"] = "Masquer les effets du fruit Control",
		["Locally hides Control's room visuals and pauses its heavy bubble animation"] = "Masque localement les effets de la salle de Control et met en pause la lourde animation de la bulle",
	},
	Vietnamese = {
		LANGUAGE = "NGÔN NGỮ",
		["Select Language"] = "Chọn ngôn ngữ",
		Gold = "Vàng",
		Red = "Đỏ",
		Green = "Xanh lá",
		Cyan = "Xanh ngọc",
		White = "Trắng",
		Magenta = "Hồng tím",
		Pink = "Hồng",
		Purple = "Tím",
		Blue = "Xanh dương",
		Black = "Đen",
		Midnight = "Đêm",
		["Custom RGB"] = "RGB tùy chỉnh",
		["Top Right"] = "Trên phải",
		["Top Left"] = "Trên trái",
		["Bottom Right"] = "Dưới phải",
		["Bottom Left"] = "Dưới trái",
		Line = "Đường",
		None = "Không",
		Tap = "Chạm",
		Hold = "Giữ",
		On = "Bật",
		Off = "Tắt",
		["Jumps After Skill"] = "Nhảy sau kỹ năng",
		Jump = "Lần nhảy",
		Jumps = "Lần nhảy",
		["Skill Aimbot"] = "Aimbot kỹ năng",
		["Soru Aimbot"] = "Aimbot Soru",
		["Auto Prediction"] = "Dự đoán tự động",
		["Safe Zone Filter"] = "Lọc vùng an toàn",
		["Target Mode"] = "Chế độ mục tiêu",
		["Target Priority"] = "Ưu tiên mục tiêu",
		["Target Switch Delay"] = "Độ trễ đổi mục tiêu",
		["360° Targeting"] = "Nhắm mục tiêu 360°",
		["Skill CamLock"] = "CamLock kỹ năng",
		["Ability Range Check"] = "Kiểm tra tầm kỹ năng",
		["Show FOV Circle"] = "Hiện vòng FOV",
		["ESP Enabled"] = "Bật ESP",
		["Speed Boost"] = "Tăng tốc",
		["Dash Boost"] = "Tăng dash",
		["Jump Boost"] = "Tăng nhảy",
		["Walk on Water"] = "Đi trên nước",
		["Walk on Lava"] = "Đi trên dung nham",
		["Auto V3"] = "V3 tự động",
		["Smart V3"] = "V3 thông minh",
		["Auto V4"] = "V4 tự động",
		["Smart V4"] = "V4 thông minh",
		["Normal Safe Mode"] = "Chế độ an toàn thường",
		["Disable Notifications"] = "Tắt thông báo",
		["Streamer Mode"] = "Chế độ streamer",
		["Hide Control Fruit Effects"] = "Ẩn hiệu ứng trái Control",
		["Locally hides Control's room visuals and pauses its heavy bubble animation"] = "Ẩn cục bộ hiệu ứng phòng Control và tạm dừng hoạt ảnh bong bóng nặng",
	},
	Indonesian = {
		LANGUAGE = "BAHASA",
		["Select Language"] = "Pilih bahasa",
		Gold = "Emas",
		Red = "Merah",
		Green = "Hijau",
		Cyan = "Sian",
		White = "Putih",
		Magenta = "Magenta",
		Pink = "Merah muda",
		Purple = "Ungu",
		Blue = "Biru",
		Black = "Hitam",
		Midnight = "Tengah malam",
		["Custom RGB"] = "RGB khusus",
		["Top Right"] = "Kanan atas",
		["Top Left"] = "Kiri atas",
		["Bottom Right"] = "Kanan bawah",
		["Bottom Left"] = "Kiri bawah",
		Line = "Garis",
		None = "Tidak ada",
		Tap = "Ketuk",
		Hold = "Tahan",
		On = "Aktif",
		Off = "Nonaktif",
		["Jumps After Skill"] = "Lompatan setelah skill",
		Jump = "Lompatan",
		Jumps = "Lompatan",
		["Skill Aimbot"] = "Aimbot skill",
		["Soru Aimbot"] = "Aimbot Soru",
		["Auto Prediction"] = "Prediksi otomatis",
		["Safe Zone Filter"] = "Filter zona aman",
		["Target Mode"] = "Mode target",
		["Target Priority"] = "Prioritas target",
		["Target Switch Delay"] = "Jeda pergantian target",
		["360° Targeting"] = "Penargetan 360°",
		["Skill CamLock"] = "CamLock skill",
		["Ability Range Check"] = "Pemeriksaan jangkauan",
		["Show FOV Circle"] = "Tampilkan lingkaran FOV",
		["ESP Enabled"] = "Aktifkan ESP",
		["Speed Boost"] = "Peningkat kecepatan",
		["Dash Boost"] = "Peningkat dash",
		["Jump Boost"] = "Peningkat lompatan",
		["Walk on Water"] = "Berjalan di air",
		["Walk on Lava"] = "Berjalan di lava",
		["Auto V3"] = "V3 otomatis",
		["Smart V3"] = "V3 pintar",
		["Auto V4"] = "V4 otomatis",
		["Smart V4"] = "V4 pintar",
		["Normal Safe Mode"] = "Mode aman normal",
		["Disable Notifications"] = "Matikan notifikasi",
		["Streamer Mode"] = "Mode streamer",
		["Hide Control Fruit Effects"] = "Sembunyikan efek buah Control",
		["Locally hides Control's room visuals and pauses its heavy bubble animation"] = "Menyembunyikan efek ruang Control secara lokal dan menjeda animasi gelembung yang berat",
	},
	Filipino = {
		LANGUAGE = "WIKA",
		["Select Language"] = "Pumili ng Wika",
		Gold = "Ginto",
		Red = "Pula",
		Green = "Berde",
		Cyan = "Cyan",
		White = "Puti",
		Magenta = "Magenta",
		Pink = "Rosas",
		Purple = "Lila",
		Blue = "Asul",
		Black = "Itim",
		Midnight = "Hatinggabi",
		["Custom RGB"] = "Custom RGB",
		["Top Right"] = "Itaas Kanan",
		["Top Left"] = "Itaas Kaliwa",
		["Bottom Right"] = "Ibaba Kanan",
		["Bottom Left"] = "Ibaba Kaliwa",
		Line = "Linya",
		None = "Wala",
		Tap = "I-tap",
		Hold = "Hawakan",
		On = "Bukas",
		Off = "Patay",
		["Jumps After Skill"] = "Mga talon pagkatapos ng skill",
		Jump = "Talon",
		Jumps = "Mga talon",
		["Skill Aimbot"] = "Skill Aimbot",
		["Soru Aimbot"] = "Soru Aimbot",
		["Auto Prediction"] = "Awtomatikong Prediction",
		["Safe Zone Filter"] = "Safe Zone Filter",
		["Target Mode"] = "Target Mode",
		["Target Priority"] = "Prayoridad ng Target",
		["Target Switch Delay"] = "Delay sa Pagpalit ng Target",
		["360° Targeting"] = "360° Targeting",
		["Skill CamLock"] = "Skill CamLock",
		["Ability Range Check"] = "Pagsuri ng Abot ng Ability",
		["Show FOV Circle"] = "Ipakita ang FOV Circle",
		["ESP Enabled"] = "I-enable ang ESP",
		["Speed Boost"] = "Speed Boost",
		["Dash Boost"] = "Dash Boost",
		["Jump Boost"] = "Jump Boost",
		["Walk on Water"] = "Maglakad sa Tubig",
		["Walk on Lava"] = "Maglakad sa Lava",
		["Auto V3"] = "Auto V3",
		["Smart V3"] = "Smart V3",
		["Auto V4"] = "Auto V4",
		["Smart V4"] = "Smart V4",
		["Normal Safe Mode"] = "Normal Safe Mode",
		["Disable Notifications"] = "I-disable ang mga Notification",
		["Streamer Mode"] = "Streamer Mode",
		["Hide Control Fruit Effects"] = "Itago ang Control Fruit Effects",
		["Locally hides Control's room visuals and pauses its heavy bubble animation"] = "Lokal na itinatago ang mga visual ng Control room at pini-pause ang mabigat na bubble animation",
	},
}) do
	tbl3[k] = tbl3[k] or {}

	for k2, value6 in pairs(value5) do
		tbl3[k][k2] = value6
	end
end

for k, value7 in pairs({
	Spanish = {
		ON = "ACTIVADO",
		OFF = "DESACTIVADO",
		TAP = "TOCAR",
		HOLD = "MANTENER",
		Enabled = "Activado",
		Disabled = "Desactivado",
		Melee = "Combate",
		Fruit = "Fruta",
		Sword = "Espada",
		Gun = "Arma",
		Weapon = "Arma",
		["Skill Key"] = "Tecla de habilidad",
		Placement = "Posición",
		Count = "Cantidad",
		Attack = "Ataque",
		Attacks = "Ataques",
		BLOCK = "BLOQUE",
		BLOCKS = "BLOQUES",
		SLOTS = "RANURAS",
		Slot = "Ranura",
		STOPPED = "DETENIDO",
		IDLE = "INACTIVO",
		EXCLUDED = "EXCLUIDO",
		Clear = "Borrar",
		Add = "Añadir",
	},
	Portuguese = {
		ON = "LIGADO",
		OFF = "DESLIGADO",
		TAP = "TOQUE",
		HOLD = "SEGURAR",
		Enabled = "Ativado",
		Disabled = "Desativado",
		Melee = "Corpo a corpo",
		Fruit = "Fruta",
		Sword = "Espada",
		Gun = "Arma",
		Weapon = "Arma",
		["Skill Key"] = "Tecla da habilidade",
		Placement = "Posição",
		Count = "Quantidade",
		Attack = "Ataque",
		Attacks = "Ataques",
		BLOCK = "BLOCO",
		BLOCKS = "BLOCOS",
		SLOTS = "ESPAÇOS",
		Slot = "Espaço",
		STOPPED = "PARADO",
		IDLE = "INATIVO",
		EXCLUDED = "EXCLUÍDO",
		Clear = "Limpar",
		Add = "Adicionar",
	},
	French = {
		ON = "ACTIVÉ",
		OFF = "DÉSACTIVÉ",
		TAP = "APPUYER",
		HOLD = "MAINTENIR",
		Enabled = "Activé",
		Disabled = "Désactivé",
		Melee = "Mêlée",
		Fruit = "Fruit",
		Sword = "Épée",
		Gun = "Arme",
		Weapon = "Arme",
		["Skill Key"] = "Touche de compétence",
		Placement = "Position",
		Count = "Nombre",
		Attack = "Attaque",
		Attacks = "Attaques",
		BLOCK = "BLOC",
		BLOCKS = "BLOCS",
		SLOTS = "EMPLACEMENTS",
		Slot = "Emplacement",
		STOPPED = "ARRÊTÉ",
		IDLE = "INACTIF",
		EXCLUDED = "EXCLU",
		Clear = "Effacer",
		Add = "Ajouter",
	},
	Vietnamese = {
		ON = "BẬT",
		OFF = "TẮT",
		TAP = "CHẠM",
		HOLD = "GIỮ",
		Enabled = "Đã bật",
		Disabled = "Đã tắt",
		Melee = "Cận chiến",
		Fruit = "Trái ác quỷ",
		Sword = "Kiếm",
		Gun = "Súng",
		Weapon = "Vũ khí",
		["Skill Key"] = "Phím kỹ năng",
		Placement = "Vị trí",
		Count = "Số lần",
		Attack = "Đòn đánh",
		Attacks = "Đòn đánh",
		BLOCK = "KHỐI",
		BLOCKS = "CÁC KHỐI",
		SLOTS = "Ô",
		Slot = "Ô",
		STOPPED = "ĐÃ DỪNG",
		IDLE = "CHỜ",
		EXCLUDED = "ĐÃ LOẠI TRỪ",
		Clear = "Xóa",
		Add = "Thêm",
	},
	Indonesian = {
		ON = "AKTIF",
		OFF = "NONAKTIF",
		TAP = "KETUK",
		HOLD = "TAHAN",
		Enabled = "Aktif",
		Disabled = "Nonaktif",
		Melee = "Jarak dekat",
		Fruit = "Buah",
		Sword = "Pedang",
		Gun = "Senjata",
		Weapon = "Senjata",
		["Skill Key"] = "Tombol skill",
		Placement = "Posisi",
		Count = "Jumlah",
		Attack = "Serangan",
		Attacks = "Serangan",
		BLOCK = "BLOK",
		BLOCKS = "BLOK",
		SLOTS = "SLOT",
		Slot = "Slot",
		STOPPED = "BERHENTI",
		IDLE = "SIAGA",
		EXCLUDED = "DIKECUALIKAN",
		Clear = "Bersihkan",
		Add = "Tambah",
	},
	Filipino = {
		ON = "BUKAS",
		OFF = "PATAY",
		TAP = "I-TAP",
		HOLD = "HAWAKAN",
		Enabled = "Naka-enable",
		Disabled = "Naka-disable",
		Melee = "Melee",
		Fruit = "Prutas",
		Sword = "Espada",
		Gun = "Baril",
		Weapon = "Sandata",
		["Skill Key"] = "Skill Key",
		Placement = "Posisyon",
		Count = "Bilang",
		Attack = "Atake",
		Attacks = "Mga Atake",
		BLOCK = "BLOCK",
		BLOCKS = "MGA BLOCK",
		SLOTS = "MGA SLOT",
		Slot = "Slot",
		STOPPED = "HUMINTO",
		IDLE = "NAKAHINTO",
		EXCLUDED = "IBINUKOD",
		Clear = "Burahin",
		Add = "Idagdag",
	},
}) do
	tbl3[k] = tbl3[k] or {}

	for k2, value8 in pairs(value7) do
		tbl3[k][k2] = value8
	end
end

local tbl5 = {}
local tbl6 = { "Spanish", "Portuguese", "French", "Vietnamese", "Indonesian", "Filipino" }
local sovereignHubInterfaceLanguage = nil
local value9 = nil
local tbl7 = {}
local value10 = nil

local function func12(flag5)
	if type(flag5) == "table" then
		return flag5
	end

	if type(flag5) ~= "string" or flag5 == "" then
		return nil
	end

	local ok, result = pcall(function()
		return game:GetService("HttpService"):JSONDecode(flag5)
	end)

	return ok and type(result) == "table" and result or nil
end

local function func13(str2)
	table.clear(tbl7)
	if str2 == nil or str2 == "English" then
		return
	end
	local tbl8 = value9
	if not tbl8 then
		return
	end
	local value11 = value10
	local flag6

	if value10 then
		flag6 = value11
	else
		flag6 = func12(tbl8.sourcesJson)
	end

	flag6 = flag6 or func12(tbl8.sources)

	if flag6 and not value10 then
		value10 = flag6
	end

	local tbl9 = func12(tbl8[str2 .. "Json"]) or func12(tbl8[str2])
	if type(flag6) ~= "table" or type(tbl9) ~= "table" then
		return
	end

	for i, item in ipairs(flag6) do
		local entry1 = tbl9[i]

		if type(item) == "string" and type(entry1) == "string" then
			tbl7[item] = entry1
		end
	end
end

_G.__SovereignHubRegisterTranslationRows = function(list1)
	if type(list1) ~= "table" then
		return
	end

	for _, item2 in ipairs(list1) do
		local flag7 = type(item2) == "table" and item2[1] or nil

		if type(flag7) == "string" then
			for i, item3 in ipairs(tbl6) do
				local entry2 = item2[i + 1]
				tbl3[item3] = tbl3[item3] or {}

				if tbl3[item3][flag7] == nil and type(entry2) == "string" then
					tbl3[item3][flag7] = entry2
				end
			end
		end
	end
end

_G.__SovereignHubRegisterTranslationPack = function(obj)
	if obj == nil then
		value9 = nil
		value10 = nil
		table.clear(tbl7)
		return
	end

	if type(obj) ~= "table" or type(obj.sources) ~= "table" and type(obj.sourcesJson) ~= "string" then
		return
	end
	value9 = obj
	value10 = nil
	func13(sovereignHubInterfaceLanguage)
end

_G.__SovereignHubRegisterTranslationPatterns = function(list2)
	if type(list2) ~= "table" then
		return
	end

	for k, value12 in pairs(list2) do
		if type(value12) == "table" then
			tbl5[k] = value12
		end
	end
end

_G.__SovereignHubRegisterTranslationRows({
	{ "FPS", "FPS", "FPS", "FPS", "FPS", "FPS" },
	{ "Ping", "Latencia", "Ping", "Latence", "Ping", "Ping" },
	{ "SERVER", "SERVIDOR", "SERVIDOR", "SERVEUR", "MÁY CHỦ", "SERVER" },
	{ "SESSION", "SESIÓN", "SESSÃO", "SESSION", "PHIÊN", "SESI" },
	{ "PLAYERS", "JUGADORES", "JOGADORES", "JOUEURS", "NGƯỜI CHƠI", "PEMAIN" },
	{ "BOUNTY", "RECOMPENSA", "RECOMPENSA", "PRIME", "TRUY NÃ", "BOUNTY" },
	{ "HONOR", "HONOR", "HONRA", "HONNEUR", "DANH DỰ", "KEHORMATAN" },
	{
		"SYNCING",
		"SINCRONIZANDO",
		"SINCRONIZANDO",
		"SYNCHRONISATION",
		"ĐANG ĐỒNG BỘ",
		"MENYINKRONKAN",
	},
	{ "Keybind", "tecla", "atalho", "raccourci", "phím tắt", "tombol pintas" },
	{ "Press", "Pulsa", "Pressione", "Appuyez", "Nhấn", "Tekan" },
	{
		"to switch to the next eligible target",
		"para cambiar al siguiente objetivo válido",
		"para mudar para o próximo alvo válido",
		"pour passer à la prochaine cible valide",
		"để chuyển sang mục tiêu hợp lệ tiếp theo",
		"untuk beralih ke target valid berikutnya",
	},
	{
		"Restock in",
		"Reposición en",
		"Reabastece em",
		"Réapprovisionnement dans",
		"Có lại sau",
		"Stok ulang dalam",
	},
	{ "more", "más", "mais", "de plus", "nữa", "lagi" },
	{ "PRIMARY", "PRINCIPAL", "PRINCIPAL", "PRINCIPAL", "CHÍNH", "UTAMA" },
	{ "MARINE", "MARINE", "MARINE", "MARINE", "HẢI QUÂN", "MARINE" },
	{ "PIRATE", "PIRATA", "PIRATA", "PIRATE", "HẢI TẶC", "BAJAK LAUT" },
	{
		"SELECTING TEAM",
		"ELIGIENDO EQUIPO",
		"ESCOLHENDO EQUIPE",
		"CHOIX DE L'ÉQUIPE",
		"ĐANG CHỌN ĐỘI",
		"MEMILIH TIM",
	},
	{ "INCLUDE", "INCLUIR", "INCLUIR", "INCLURE", "BAO GỒM", "SERTAKAN" },
	{ "EXCLUDE", "EXCLUIR", "EXCLUIR", "EXCLURE", "LOẠI TRỪ", "KECUALIKAN" },
	{ "Player", "Jugador", "Jogador", "Joueur", "Người chơi", "Pemain" },
	{
		"Identity hidden",
		"Identidad oculta",
		"Identidade oculta",
		"Identité masquée",
		"Đã ẩn danh tính",
		"Identitas disembunyikan",
	},
	{ "AUTO", "AUTO", "AUTO", "AUTO", "TỰ ĐỘNG", "OTOMATIS" },
	{ "MANUAL", "MANUAL", "MANUAL", "MANUEL", "THỦ CÔNG", "MANUAL" },
	{
		"Show Less",
		"Mostrar menos",
		"Mostrar menos",
		"Afficher moins",
		"Hiện ít hơn",
		"Tampilkan lebih sedikit",
	},
	{
		"Show All Checks",
		"Mostrar todas las comprobaciones",
		"Mostrar todas as verificações",
		"Afficher toutes les vérifications",
		"Hiện tất cả kiểm tra",
		"Tampilkan semua pemeriksaan",
	},
	{
		"Show All Skills",
		"Mostrar todas las habilidades",
		"Mostrar todas as habilidades",
		"Afficher toutes les compétences",
		"Hiện tất cả kỹ năng",
		"Tampilkan semua kemampuan",
	},
	{ "IN", "DENTRO", "DENTRO", "À PORTÉE", "TRONG TẦM", "DALAM JANGKAUAN" },
	{ "OUT", "FUERA", "FORA", "HORS PORTÉE", "NGOÀI TẦM", "DI LUAR JANGKAUAN" },
	{ "READY", "LISTO", "PRONTO", "PRÊT", "SẴN SÀNG", "SIAP" },
	{ "Ken Off", "Ken desactivado", "Ken desligado", "Ken désactivé", "Ken tắt", "Ken mati" },
	{ "PvP Off", "PvP desactivado", "PvP desligado", "PvP désactivé", "PvP tắt", "PvP mati" },
	{ "In Combat", "En combate", "Em combate", "En combat", "Đang giao tranh", "Dalam pertarungan" },
	{ "Safe Zone", "Zona segura", "Zona segura", "Zone sûre", "Khu an toàn", "Zona aman" },
	{ "PvP On", "PvP activado", "PvP ligado", "PvP activé", "PvP bật", "PvP aktif" },
	{
		"Exclude All",
		"Excluir a todos",
		"Excluir todos",
		"Tout exclure",
		"Loại trừ tất cả",
		"Kecualikan semua",
	},
	{ "Clear All", "Borrar todo", "Limpar tudo", "Tout effacer", "Xóa tất cả", "Bersihkan semua" },
	{ "WAIT", "ESPERA", "AGUARDE", "ATTENTE", "CHỜ", "TUNGGU" },
	{ "STOP", "PARAR", "PARAR", "ARRÊT", "DỪNG", "BERHENTI" },
	{ "MACRO", "MACRO", "MACRO", "MACRO", "MACRO", "MAKRO" },
	{ "TAGGED", "EN COMBATE", "EM COMBATE", "EN COMBAT", "ĐANG GIAO TRANH", "DALAM PERTARUNGAN" },
	{ "COPY", "COPIAR", "COPIAR", "COPIER", "SAO CHÉP", "SALIN" },
	{ "PC ONLY", "SOLO PC", "SOMENTE PC", "PC UNIQUEMENT", "CHỈ PC", "KHUSUS PC" },
	{
		"Press a key",
		"Pulsa una tecla",
		"Pressione uma tecla",
		"Appuyez sur une touche",
		"Nhấn một phím",
		"Tekan sebuah tombol",
	},
	{
		"Esc to cancel",
		"Esc para cancelar",
		"Esc para cancelar",
		"Échap pour annuler",
		"Esc để hủy",
		"Esc untuk batal",
	},
	{
		"Backspace to clear",
		"Retroceso para borrar",
		"Backspace para limpar",
		"Retour arrière pour effacer",
		"Backspace để xóa",
		"Backspace untuk menghapus",
	},
	{
		"Shared with:",
		"Compartida con:",
		"Compartilhada com:",
		"Partagée avec :",
		"Dùng chung với:",
		"Digunakan bersama:",
	},
	{ "LANGUAGE", "IDIOMA", "IDIOMA", "LANGUE", "NGÔN NGỮ", "BAHASA" },
	{ "Language", "Idioma", "Idioma", "Langue", "Ngôn ngữ", "Bahasa" },
	{
		"Auto Detect",
		"Detección automática",
		"Detecção automática",
		"Détection automatique",
		"Tự động phát hiện",
		"Deteksi otomatis",
	},
	{
		"Changes every script label immediately and saves for future sessions.",
		"Cambia inmediatamente todos los textos del script y guarda la selección para futuras sesiones.",
		"Altera imediatamente todos os textos do script e salva a seleção para sessões futuras.",
		"Modifie immédiatement tous les textes du script et enregistre le choix pour les prochaines sessions.",
		"Thay đổi ngay toàn bộ văn bản của script và lưu lựa chọn cho những lần sau.",
		"Langsung mengubah semua teks script dan menyimpan pilihan untuk sesi berikutnya.",
	},
	{
		"Language Changed",
		"Idioma cambiado",
		"Idioma alterado",
		"Langue modifiée",
		"Đã đổi ngôn ngữ",
		"Bahasa diubah",
	},
	{
		"The interface is now using your selected language.",
		"La interfaz ahora usa el idioma seleccionado.",
		"A interface agora usa o idioma selecionado.",
		"L'interface utilise maintenant la langue sélectionnée.",
		"Giao diện hiện đang dùng ngôn ngữ bạn đã chọn.",
		"Antarmuka sekarang menggunakan bahasa pilihan Anda.",
	},
	{
		"ON-SCREEN BUTTONS",
		"BOTONES EN PANTALLA",
		"BOTÕES NA TELA",
		"BOUTONS À L'ÉCRAN",
		"NÚT TRÊN MÀN HÌNH",
		"TOMBOL DI LAYAR",
	},
	{
		"Choose which shortcuts appear over the game. These switches only show or hide buttons.",
		"Elige qué atajos aparecen sobre el juego. Estos interruptores solo muestran u ocultan botones.",
		"Escolha quais atalhos aparecem durante o jogo. Essas opções apenas mostram ou ocultam botões.",
		"Choisissez les raccourcis qui apparaissent dans le jeu. Ces options affichent ou masquent uniquement les boutons.",
		"Chọn các phím tắt xuất hiện trong trò chơi. Các công tắc này chỉ hiển thị hoặc ẩn nút.",
		"Pilih pintasan yang muncul di game. Pengaturan ini hanya menampilkan atau menyembunyikan tombol.",
	},
	{
		"Show Aimbot",
		"Mostrar Aimbot",
		"Mostrar Aimbot",
		"Afficher l'Aimbot",
		"Hiện Aimbot",
		"Tampilkan Aimbot",
	},
	{
		"Show Macro",
		"Mostrar Macro",
		"Mostrar Macro",
		"Afficher la Macro",
		"Hiện Macro",
		"Tampilkan Makro",
	},
	{
		"Show Target Lock",
		"Mostrar bloqueo de objetivo",
		"Mostrar bloqueio de alvo",
		"Afficher le verrouillage de cible",
		"Hiện Khóa mục tiêu",
		"Tampilkan Kunci Target",
	},
	{
		"Show Fast Attack",
		"Mostrar ataque rápido",
		"Mostrar ataque rápido",
		"Afficher l'attaque rapide",
		"Hiện Tấn công nhanh",
		"Tampilkan Serangan Cepat",
	},
	{
		"Show Soru Aim",
		"Mostrar Soru Aim",
		"Mostrar Mira Soru",
		"Afficher Soru Aim",
		"Hiện Soru Aim",
		"Tampilkan Soru Aim",
	},
	{
		"Show Reset Character",
		"Mostrar reinicio de personaje",
		"Mostrar reinício de personagem",
		"Afficher la réinitialisation du personnage",
		"Hiện Đặt lại nhân vật",
		"Tampilkan Reset Karakter",
	},
	{
		"Show Sang Z",
		"Mostrar Sang Z",
		"Mostrar Sang Z",
		"Afficher Sang Z",
		"Hiện Sang Z",
		"Tampilkan Sang Z",
	},
	{
		"Show Ragdoll",
		"Mostrar Ragdoll",
		"Mostrar Ragdoll",
		"Afficher Ragdoll",
		"Hiện Ragdoll",
		"Tampilkan Ragdoll",
	},
	{
		"Show Diamond Boost",
		"Mostrar Diamond Boost",
		"Mostrar Diamond Boost",
		"Afficher Diamond Boost",
		"Hiện Diamond Boost",
		"Tampilkan Diamond Boost",
	},
	{
		"Shows a shortcut for turning Skill Aimbot on or off.",
		"Muestra un atajo para activar o desactivar Skill Aimbot.",
		"Mostra um atalho para ativar ou desativar o Skill Aimbot.",
		"Affiche un raccourci pour activer ou désactiver Skill Aimbot.",
		"Hiển thị phím tắt để bật hoặc tắt Skill Aimbot.",
		"Menampilkan pintasan untuk mengaktifkan atau menonaktifkan Skill Aimbot.",
	},
	{
		"Shows a shortcut for starting or stopping Smart Macro.",
		"Muestra un atajo para iniciar o detener Smart Macro.",
		"Mostra um atalho para iniciar ou parar o Smart Macro.",
		"Affiche un raccourci pour démarrer ou arrêter Smart Macro.",
		"Hiển thị phím tắt để bắt đầu hoặc dừng Smart Macro.",
		"Menampilkan pintasan untuk memulai atau menghentikan Smart Macro.",
	},
	{
		"Shows a shortcut for locking or releasing your current target.",
		"Muestra un atajo para bloquear o liberar tu objetivo actual.",
		"Mostra um atalho para bloquear ou liberar seu alvo atual.",
		"Affiche un raccourci pour verrouiller ou libérer votre cible actuelle.",
		"Hiển thị phím tắt để khóa hoặc thả mục tiêu hiện tại.",
		"Menampilkan pintasan untuk mengunci atau melepaskan target saat ini.",
	},
	{
		"Shows a shortcut for turning Fast Attack on or off.",
		"Muestra un atajo para activar o desactivar Fast Attack.",
		"Mostra um atalho para ativar ou desativar o Fast Attack.",
		"Affiche un raccourci pour activer ou désactiver Fast Attack.",
		"Hiển thị phím tắt để bật hoặc tắt Fast Attack.",
		"Menampilkan pintasan untuk mengaktifkan atau menonaktifkan Fast Attack.",
	},
	{
		"Shows a one-tap aimed Soru shortcut.",
		"Muestra un atajo de Soru dirigido con un solo toque.",
		"Mostra um atalho de Soru direcionado com um toque.",
		"Affiche un raccourci Soru ciblé en un seul appui.",
		"Hiển thị phím tắt Soru nhắm mục tiêu bằng một lần chạm.",
		"Menampilkan pintasan Soru terarah dengan satu ketukan.",
	},
	{
		"Shows a reset shortcut that only works outside combat.",
		"Muestra un atajo de reinicio que solo funciona fuera del combate.",
		"Mostra um atalho de reinício que funciona apenas fora do combate.",
		"Affiche un raccourci de réinitialisation utilisable uniquement hors combat.",
		"Hiển thị phím tắt đặt lại chỉ hoạt động ngoài chiến đấu.",
		"Menampilkan pintasan reset yang hanya berfungsi di luar pertarungan.",
	},
	{
		"Shows a shortcut for the Sanguine Z boost.",
		"Muestra un atajo para el impulso Sanguine Z.",
		"Mostra um atalho para o impulso Sanguine Z.",
		"Affiche un raccourci pour le boost Sanguine Z.",
		"Hiển thị phím tắt cho tăng cường Sanguine Z.",
		"Menampilkan pintasan untuk peningkatan Sanguine Z.",
	},
	{
		"Shows a shortcut for the ragdoll-after-skill feature.",
		"Muestra un atajo para la función de ragdoll después de una habilidad.",
		"Mostra um atalho para o recurso de ragdoll após uma habilidade.",
		"Affiche un raccourci pour la fonction de ragdoll après une compétence.",
		"Hiển thị phím tắt cho tính năng ragdoll sau kỹ năng.",
		"Menampilkan pintasan untuk fitur ragdoll setelah skill.",
	},
	{
		"Shows a shortcut for the Diamond M1 boost.",
		"Muestra un atajo para el impulso Diamond M1.",
		"Mostra um atalho para o impulso Diamond M1.",
		"Affiche un raccourci pour le boost Diamond M1.",
		"Hiển thị phím tắt cho tăng cường Diamond M1.",
		"Menampilkan pintasan untuk peningkatan Diamond M1.",
	},
	{
		"SMART MACRO VIDEO GUIDE",
		"GUÍA EN VIDEO DE SMART MACRO",
		"GUIA EM VÍDEO DO SMART MACRO",
		"GUIDE VIDÉO DE SMART MACRO",
		"VIDEO HƯỚNG DẪN SMART MACRO",
		"PANDUAN VIDEO SMART MACRO",
		"SMART MACRO VIDEO GUIDE",
	},
	{
		"Video guide link copied!",
		"¡Enlace de la guía en video copiado!",
		"Link do guia em vídeo copiado!",
		"Lien du guide vidéo copié !",
		"Đã sao chép liên kết video hướng dẫn!",
		"Tautan panduan video disalin!",
		"Nakopya ang link ng video guide!",
	},
})

local function func14()
	local tbl10 = {}

	pcall(function()
		local LocalizationService = game:GetService("LocalizationService")

		if type(LocalizationService.RobloxLocaleId) == "string" then
			table.insert(tbl10, LocalizationService.RobloxLocaleId)
		end

		if type(LocalizationService.SystemLocaleId) == "string" then
			table.insert(tbl10, LocalizationService.SystemLocaleId)
		end
	end)

	for _, item4 in ipairs(tbl10) do
		local str3 = tostring(item4):lower()
		if str3:match("^es") then
			return "Spanish"
		end

		if str3:match("^pt") then
			return "Portuguese"
		end

		if str3:match("^fr") then
			return "French"
		end

		if str3:match("^vi") then
			return "Vietnamese"
		end

		if str3:match("^id") then
			return "Indonesian"
		end

		if str3:match("^fil") or str3:match("^tl") then
			return "Filipino"
		end
	end

	return "English"
end

local function func15()
	local json = func6("Sovereign HubLanguage_v1.json")

	if json then
		local ok, result = pcall(function()
			return game:GetService("HttpService"):JSONDecode(json)
		end)

		ok = ok and type(result) == "table" and result.language or nil
		if tbl2[ok] then
			return ok
		end
	end

	return "Auto"
end

local result1 = func15()
sovereignHubInterfaceLanguage = result1 == "Auto" and func14() or result1
local tbl11 = {}

local function sovereignHubTranslate(text)
	if type(text) ~= "string" or sovereignHubInterfaceLanguage == "English" then
		return text
	end
	local entry3 = tbl3[sovereignHubInterfaceLanguage]
	if not entry3 then
		return text
	end
	local value13 = entry3[text] or tbl7[text]
	if value13 then
		return value13
	end
	local match, str4, flag8 = text:match("^(MELEE|FRUIT|SWORD|GUN) M1%s+•%s+(%d+) (ATTACKS?)$")
	match = match or text:match("^(MELEE|FRUIT|SWORD|GUN) M1$")

	if match then
		local str5 = match:sub(1, 1) .. match:sub(2):lower()
		local obj1 = entry3[str5] or str5
		if str4 then
			local str6 = flag8 == "ATTACK" and "Attack" or "Attacks"
			return obj1:upper() .. " M1  •  " .. str4 .. " " .. (entry3[str6] or str6):upper()
		end
		return obj1:upper() .. " M1"
	end

	local match2, str7, str8 = text:match("^(%s*)(.-)(%s*)$")

	if str7 then
		str7 = entry3[str7] or tbl7[str7]
	end

	if str7 then
		return match2 .. str7 .. str8
	end
	local tbl12 = tbl5[sovereignHubInterfaceLanguage] or {}

	for _, item5 in ipairs(tbl12) do
		local first1 = item5[1]
		local second1 = item5[2]

		if type(first1) == "string" and type(second1) == "string" then
			local str9, flag9 = text:gsub(first1, second1)
			if flag9 > 0 then
				return str9
			end
		end
	end

	return text
end

local function sovereignHubSetLanguagePreference(flag10)
	if not tbl2[flag10] then
		return false
	end
	local flag11 = result1
	local flag12 = sovereignHubInterfaceLanguage
	result1 = flag10
	sovereignHubInterfaceLanguage = flag10 == "Auto" and func14() or flag10
	local sovereignHubLoadGeneratedTranslation = _G.__SovereignHubLoadGeneratedTranslationPack

	if type(sovereignHubLoadGeneratedTranslation) == "function" then
		sovereignHubLoadGeneratedTranslation(sovereignHubInterfaceLanguage)
	else
		func13(sovereignHubInterfaceLanguage)
	end

	getgenv().__SovereignHubLanguagePreference = result1
	getgenv().__SovereignHubInterfaceLanguage = sovereignHubInterfaceLanguage
	func7("Sovereign HubLanguage_v1.json", game:GetService("HttpService"):JSONEncode({ language = result1 }))

	if flag11 ~= result1 or flag12 ~= sovereignHubInterfaceLanguage then
		for _, item6 in ipairs(tbl11) do
			pcall(item6, sovereignHubInterfaceLanguage, flag12, result1)
		end
	end

	return true
end

getgenv().__SovereignHubLanguagePreference = result1
getgenv().__SovereignHubInterfaceLanguage = sovereignHubInterfaceLanguage
_G.__SovereignHubTranslate = sovereignHubTranslate
_G.__SovereignHubLanguageOptions = sovereignHubLanguageOptions
_G.__SovereignHubSetLanguagePreference = sovereignHubSetLanguagePreference

_G.__SovereignHubOnLanguageChanged = function(param4)
	if type(param4) ~= "function" then
		return function()
		end
	end
	table.insert(tbl11, param4)
	local flag13 = true

	return function()
		if not flag13 then
			return
		end
		flag13 = false
		local foundAt = table.find(tbl11, param4)

		if foundAt then
			table.remove(tbl11, foundAt)
		end
	end
end

local function func16()
	local sovereignHubNotificationsDisabled = getgenv().__SovereignHubNotificationsDisabled
	if sovereignHubNotificationsDisabled ~= nil then
		return sovereignHubNotificationsDisabled ~= true
	end
	local sovereignHubNotificationsEnabled = getgenv().__SovereignHubNotificationsEnabled

	if sovereignHubNotificationsEnabled ~= nil then
		local sovereignHubNotificationsDisabled2 = sovereignHubNotificationsEnabled == false
		getgenv().__SovereignHubNotificationsDisabled = sovereignHubNotificationsDisabled2
		getgenv().__SovereignHubNotificationsEnabled = nil
		return not sovereignHubNotificationsDisabled2
	end

	local json = func6("Sovereign HubConfig_v1.json")

	if json then
		local ok, result = pcall(function()
			return game:GetService("HttpService"):JSONDecode(json)
		end)

		if ok and type(result) == "table" then
			local sovereignHubNotificationsDisabled2 = result.DisableNotifications == true

			if result.DisableNotifications == nil and result.NotificationsEnabled ~= nil then
				sovereignHubNotificationsDisabled2 = result.NotificationsEnabled == false
			end

			getgenv().__SovereignHubNotificationsDisabled = sovereignHubNotificationsDisabled2
			return not sovereignHubNotificationsDisabled2
		end
	end

	getgenv().__SovereignHubNotificationsDisabled = false
	return true
end

local genv = getgenv()
local sovereignHubLoaderController = genv.__SovereignHubLoaderController

if genv.SovereignHubScriptLoaded == true then
	local sovereignHubShowInterface = _G.__SovereignHubShowInterface

	if type(sovereignHubShowInterface) == "function" then
		pcall(sovereignHubShowInterface)
	end

	if func16() then
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Sovereign Hub", Text = "Script is already running!", Duration = 4 })
		end)
	end

	return
end

local now = os.clock()
local flag14 = type(sovereignHubLoaderController) == "table" and sovereignHubLoaderController.disposed ~= true and sovereignHubLoaderController.ownsLaunch == true

if flag14 then
	flag14 = now - (tonumber(sovereignHubLoaderController.updatedAt) or 0) < 120
end

if flag14 then
	if type(sovereignHubLoaderController.focus) == "function" then
		pcall(sovereignHubLoaderController.focus, sovereignHubLoaderController)
	end

	return
end

if type(sovereignHubLoaderController) == "table" and type(sovereignHubLoaderController.dispose) == "function" then
	pcall(sovereignHubLoaderController.dispose, sovereignHubLoaderController, "stale launch replaced")
end

local sovereignHubLoaderController2 = { version = 4, state = "BOOT", purpose = "launch" }
sovereignHubLoaderController2.launchGeneration = (tonumber(genv.__SovereignHubLoaderGeneration) or 0) + 1
sovereignHubLoaderController2.validationGeneration = 0
sovereignHubLoaderController2.monitorGeneration = 0
sovereignHubLoaderController2.selectionCommitted = false
sovereignHubLoaderController2.initializationCommitted = false
sovereignHubLoaderController2.resolvedExperience = nil
sovereignHubLoaderController2.authenticatedKey = nil
sovereignHubLoaderController2.cancelled = false
sovereignHubLoaderController2.disposed = false
sovereignHubLoaderController2.ownsLaunch = true
sovereignHubLoaderController2.updatedAt = now
sovereignHubLoaderController2.gui = nil
sovereignHubLoaderController2.blur = nil
sovereignHubLoaderController2.loaderConnections = {}
sovereignHubLoaderController2.activeKey = nil
genv.__SovereignHubLoaderGeneration = sovereignHubLoaderController2.launchGeneration
genv.__SovereignHubLoaderController = sovereignHubLoaderController2
genv.__SovereignHubLaunchInProgress = true

local tbl13 = {
	BOOT = { AUTH = true, VALIDATING = true, CANCELLED = true, DISPOSED = true },
	AUTH = { VALIDATING = true, CANCELLED = true, DISPOSED = true },
	AUTH_ERROR = { VALIDATING = true, CANCELLED = true, DISPOSED = true },
	VALIDATING = {
		AUTH_ERROR = true,
		MODE_SELECT = true,
		INITIALIZING = true,
		READY = true,
		CANCELLED = true,
		DISPOSED = true,
	},
	MODE_SELECT = { INITIALIZING = true, CANCELLED = true, DISPOSED = true },
	INITIALIZING = { READY = true, CANCELLED = true, DISPOSED = true },
	READY = { AUTH = true, SWITCHING = true, DISPOSED = true },
	SWITCHING = { REVALIDATING = true, CANCELLED = true, DISPOSED = true },
	REVALIDATING = { INITIALIZING = true, CANCELLED = true, DISPOSED = true },
	CANCELLED = { DISPOSED = true },
	DISPOSED = {},
}

local value14 = nil

sovereignHubLoaderController2.isCurrent = function(self)
	return genv.__SovereignHubLoaderController == self and self.disposed ~= true
end

sovereignHubLoaderController2.transition = function(self, state, flag15)
	if not self:isCurrent() or self.cancelled or self.disposed then
		return false
	end

	if flag15 and self.state ~= flag15 then
		return false
	end

	if not (tbl13[self.state] and tbl13[self.state][state]) then
		return false
	end
	self.state = state
	self.updatedAt = os.clock()
	return true
end

sovereignHubLoaderController2.ownsAttempt = function(obj, flag16, flag17, flag18)
	return obj:isCurrent() and not obj.cancelled and not obj.disposed and obj.launchGeneration == flag16 and obj.validationGeneration == flag17 and (flag18 == nil or obj.state == flag18)
end

sovereignHubLoaderController2.releaseLaunchOwnership = function(self)
	self.ownsLaunch = false

	if genv.__SovereignHubLoaderController == self then
		genv.__SovereignHubLaunchInProgress = false
	end
end

sovereignHubLoaderController2.focus = function(obj)
	obj.updatedAt = os.clock()

	if obj.gui then
		pcall(function()
			obj.gui.Enabled = true
		end)
	end
end

_G.__SovereignHubCancelLoader = function()
	if sovereignHubLoaderController2:isCurrent() and type(value14) == "function" then
		value14("cancel requested")
	end
end

local value15 = nil
local value16 = nil
local sovereignHubKeyAccessState = getgenv().__SovereignHubKeyAccessState or {}
getgenv().__SovereignHubKeyAccessState = sovereignHubKeyAccessState
-- NO_KEY_MODE: Sovereign Hub does not require an access key.
sovereignHubKeyAccessState.valid = true
sovereignHubKeyAccessState.permanent = true
sovereignHubKeyAccessState.expiresAt = nil
sovereignHubKeyAccessState.checkedAt = os.time()

local function func17()
	local sovereignHubRefreshHeaderKeyStatus = getgenv().__SovereignHubRefreshHeaderKeyStatus

	if type(sovereignHubRefreshHeaderKeyStatus) == "function" then
		pcall(sovereignHubRefreshHeaderKeyStatus)
	end
end

local function func18()
	sovereignHubKeyAccessState.valid = false
	sovereignHubKeyAccessState.permanent = false
	sovereignHubKeyAccessState.expiresAt = nil
	sovereignHubKeyAccessState.checkedAt = os.time()
	func17()
end

local function func19(flag19)
	sovereignHubKeyAccessState.valid = true
	sovereignHubKeyAccessState.permanent = flag19 and flag19.permanent == true or false
	sovereignHubKeyAccessState.expiresAt = flag19 and tonumber(flag19.expires_at) or nil
	sovereignHubKeyAccessState.checkedAt = os.time()
	func17()
end

local function func20()
	for _, loaderConnection in ipairs(sovereignHubLoaderController2.loaderConnections) do
		pcall(function()
			loaderConnection:Disconnect()
		end)
	end

	table.clear(sovereignHubLoaderController2.loaderConnections)
end

local function func21()
	sovereignHubLoaderController2.suppressDestroy = true
	func20()

	if value15 then
		pcall(function()
			value15:Destroy()
		end)

		value15 = nil
	end

	if value16 then
		pcall(function()
			value16:Destroy()
		end)

		value16 = nil
	end

	sovereignHubLoaderController2.gui = nil
	sovereignHubLoaderController2.blur = nil
	sovereignHubLoaderController2.suppressDestroy = false
end

local function func22(param5, ...)
	local sovereignHubSpawnRuntimeTask = _G.__SovereignHubSpawnRuntimeTask
	if type(sovereignHubSpawnRuntimeTask) == "function" then
		return sovereignHubSpawnRuntimeTask(param5, ...)
	end
	return task.spawn(param5, ...)
end

local function func23(param6, flag20)
	if sovereignHubLoaderController2.disposed then
		return
	end
	sovereignHubLoaderController2.validationGeneration = sovereignHubLoaderController2.validationGeneration + 1
	sovereignHubLoaderController2.monitorGeneration = sovereignHubLoaderController2.monitorGeneration + 1
	sovereignHubLoaderController2.cancelled = true

	if sovereignHubLoaderController2.state ~= "DISPOSED" then
		if sovereignHubLoaderController2.state ~= "CANCELLED" and tbl13[sovereignHubLoaderController2.state].CANCELLED then
			sovereignHubLoaderController2.state = "CANCELLED"
		end

		sovereignHubLoaderController2.state = "DISPOSED"
	end

	sovereignHubLoaderController2.disposed = true
	sovereignHubLoaderController2.updatedAt = os.clock()

	if flag20 ~= false then
		func21()
	else
		func20()
	end

	sovereignHubLoaderController2:releaseLaunchOwnership()

	if genv.__SovereignHubLoaderController == sovereignHubLoaderController2 then
		genv.__SovereignHubLoaderController = nil
	end
end

sovereignHubLoaderController2.dispose = function(param7, param8)
	func23(param8, true)
end

value14 = function()
	if not sovereignHubLoaderController2:isCurrent() or sovereignHubLoaderController2.disposed then
		return
	end
	sovereignHubLoaderController2.validationGeneration = sovereignHubLoaderController2.validationGeneration + 1
	func21()

	if sovereignHubLoaderController2.purpose == "replace-key" and genv.SovereignHubScriptLoaded == true then
		sovereignHubLoaderController2.cancelled = false
		sovereignHubLoaderController2.state = "READY"
		sovereignHubLoaderController2.purpose = nil
		sovereignHubLoaderController2.updatedAt = os.clock()
		return
	end

	sovereignHubLoaderController2.cancelled = true
	sovereignHubLoaderController2.state = "CANCELLED"
	sovereignHubLoaderController2:releaseLaunchOwnership()
	sovereignHubLoaderController2.state = "DISPOSED"
	sovereignHubLoaderController2.disposed = true

	if genv.__SovereignHubLoaderController == sovereignHubLoaderController2 then
		genv.__SovereignHubLoaderController = nil
	end
end

_G.__SovereignHubKeyValidationCleanup = function()
	func23("runtime cleanup", true)
	func18()
end

_G.__SovereignHubMarkRuntimeReady = function()
	if not sovereignHubLoaderController2:isCurrent() or sovereignHubLoaderController2.state ~= "INITIALIZING" then
		return false
	end

	if not sovereignHubLoaderController2:transition("READY", "INITIALIZING") then
		return false
	end
	sovereignHubLoaderController2.purpose = nil
	sovereignHubLoaderController2:releaseLaunchOwnership()
	return true
end

local value17 = nil

local function func24(_)
	-- Key system disabled by Sovereign Hub build.
	return false
end
local function func25()
	return nil
end

local function func26(_)
	-- Key monitoring intentionally disabled.
	return false
end;(function(...) end)(function(...) end)
--// Sovereign Hub Aimbot System
--// Added as a self-contained runtime module because the supplied source only
--// contained the aimbot labels/config references, not the original implementation.

if not getgenv().__SovereignHubAimbotLoaded then
	getgenv().__SovereignHubAimbotLoaded = true

	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local CoreGui = game:GetService("CoreGui")
	local Workspace = game:GetService("Workspace")
	local LocalPlayer = Players.LocalPlayer
	local Camera = Workspace.CurrentCamera

	local Config = {
		Enabled = false,
		HoldToAim = false,
		SkillAimbot = false,
		SoruAimbot = false,
		SkillCamLock = false,
		AutoPrediction = true,
		Prediction = 0.13,
		FOV = 180,
		ShowFOV = true,
		TargetMode = "Closest to Mouse",
		TargetPriority = "Closest",
		TargetSwitchDelay = 0.12,
		TargetPart = "HumanoidRootPart",
		MaxDistance = 2000,
		AbilityRangeCheck = true,
		["360Targeting"] = false,
		TeamCheck = false,
		WallCheck = false,
		SafeZoneFilter = true,
	}

	local State = {
		Target = nil,
		LastSwitch = 0,
		Holding = false,
	}

	local function getGuiParent()
		local ok, hui = pcall(function() return gethui() end)
		if ok and hui then return hui end
		return CoreGui
	end

	-- WindUI interface (no WindUI key system; the hub remains key-free).
	local WindUI = nil
	local okWind, windResult = pcall(function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
	end)
	if okWind then
		WindUI = windResult
	end

	if WindUI then
		local Window = WindUI:CreateWindow({
			Title = "Sovereign Hub",
			Author = "Sovereign Hub",
			Icon = "locate-fixed",
			Folder = "SovereignHub",
			Theme = "Dark",
			NewElements = true,
			HideSearchBar = false,
			OpenButton = { Enabled = true, Title = "Open Sovereign Hub", Draggable = true },
		})

		local AimTab = Window:Tab({ Title = "Aimbot", Icon = "locate-fixed" })
		AimTab:Section({ Title = "Main Aimbot", Opened = true })
		AimTab:Toggle({ Title = "Aimbot", Value = Config.Enabled, Callback = function(v) Config.Enabled = v end })
		AimTab:Toggle({ Title = "Hold To Aim", Value = Config.HoldToAim, Callback = function(v) Config.HoldToAim = v end })
		AimTab:Toggle({ Title = "Skill Aimbot", Value = Config.SkillAimbot, Callback = function(v) Config.SkillAimbot = v end })
		AimTab:Toggle({ Title = "Soru Aimbot", Value = Config.SoruAimbot, Callback = function(v) Config.SoruAimbot = v end })
		AimTab:Toggle({ Title = "Skill CamLock", Value = Config.SkillCamLock, Callback = function(v) Config.SkillCamLock = v end })

		AimTab:Section({ Title = "Targeting", Opened = true })
		AimTab:Dropdown({
			Title = "Target Mode",
			Values = { "Closest to Mouse", "Closest Distance" },
			Value = Config.TargetMode,
			Callback = function(v) Config.TargetMode = v end,
		})
		AimTab:Dropdown({
			Title = "Target Priority",
			Values = { "Closest", "Lowest Health", "Distance" },
			Value = Config.TargetPriority,
			Callback = function(v) Config.TargetPriority = v end,
		})
		AimTab:Dropdown({
			Title = "Target Part",
			Values = { "HumanoidRootPart", "Head" },
			Value = Config.TargetPart,
			Callback = function(v) Config.TargetPart = v end,
		})
		AimTab:Slider({
			Title = "Target Switch Delay",
			Step = 0.01,
			Value = { Min = 0, Max = 1, Default = Config.TargetSwitchDelay },
			Callback = function(v) Config.TargetSwitchDelay = v end,
		})
\n		AimTab:Section({ Title = "Prediction & FOV", Opened = true })
		AimTab:Toggle({ Title = "Auto Prediction", Value = Config.AutoPrediction, Callback = function(v) Config.AutoPrediction = v end })
		AimTab:Slider({
			Title = "Prediction",
			Step = 0.01,
			Value = { Min = 0, Max = 0.5, Default = Config.Prediction },
			Callback = function(v) Config.Prediction = v end,
		})
		AimTab:Slider({
			Title = "FOV",
			Step = 5,
			Value = { Min = 30, Max = 600, Default = Config.FOV },
			Callback = function(v) Config.FOV = v end,
		})
		AimTab:Toggle({ Title = "Show FOV Circle", Value = Config.ShowFOV, Callback = function(v) Config.ShowFOV = v end })
		AimTab:Toggle({ Title = "360° Targeting", Value = Config["360Targeting"], Callback = function(v) Config["360Targeting"] = v end })

		AimTab:Section({ Title = "Filters", Opened = true })
		AimTab:Toggle({ Title = "Safe Zone Filter", Value = Config.SafeZoneFilter, Callback = function(v) Config.SafeZoneFilter = v end })
		AimTab:Toggle({ Title = "Team Check", Value = Config.TeamCheck, Callback = function(v) Config.TeamCheck = v end })
		AimTab:Toggle({ Title = "Wall Check", Value = Config.WallCheck, Callback = function(v) Config.WallCheck = v end })
		AimTab:Toggle({ Title = "Ability Range Check", Value = Config.AbilityRangeCheck, Callback = function(v) Config.AbilityRangeCheck = v end })
\n		AimTab:Paragraph({
			Title = "Sovereign Hub Aimbot",
			Desc = "WindUI controls are connected directly to the aimbot runtime. Skill/Soru toggles provide the aim mode; game-specific skill remotes are not invented.",
			Image = "info",
		})
	else
		warn("[Sovereign Hub] WindUI failed to load; aimbot runtime remains available but no fallback UI is created.")
	end

	local fovCircle
	pcall(function()
		if Drawing and Drawing.new then
			fovCircle = Drawing.new("Circle")
			fovCircle.Thickness = 1.5
			fovCircle.NumSides = 64
			fovCircle.Filled = false
			fovCircle.Color = Color3.fromRGB(255,255,255)
			fovCircle.Transparency = 0.8
		end
	end)

	local function isSafe(character)
		if not Config.SafeZoneFilter then return false end
		local safe = character:GetAttribute("SafeZone")
		if safe == true then return true end
		safe = character:GetAttribute("InSafeZone")
		if safe == true then return true end
		local folder = character:FindFirstChild("SafeZone")
		return folder ~= nil and folder:IsA("BoolValue") and folder.Value == true
	end

	local function getPart(character)
		return character:FindFirstChild(Config.TargetPart) or character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
	end

	local function validTarget(player)
		if player == LocalPlayer then return nil end
		if Config.TeamCheck and LocalPlayer.Team ~= nil and player.Team == LocalPlayer.Team then return nil end
		local character = player.Character
		if not character then return nil end
		if Config.SafeZoneFilter and isSafe(character) then return nil end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then return nil end
		local part = getPart(character)
		if not part then return nil end
		local distance = (Camera.CFrame.Position - part.Position).Magnitude
		if distance > Config.MaxDistance then return nil end
		if Config.WallCheck then
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = {LocalPlayer.Character, character}
			local hit = Workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, params)
			if hit then return nil end
		end
		local screen, visible = Camera:WorldToViewportPoint(part.Position)
		if not visible then return nil end
		return part, distance, Vector2.new(screen.X, screen.Y)
	end

	local function getMousePosition()
		local p = UserInputService:GetMouseLocation()
		return Vector2.new(p.X, p.Y)
	end

	local function chooseTarget()
		local mouse = getMousePosition()
		local best, bestMetric
		for _, player in ipairs(Players:GetPlayers()) do
			local part, distance, screen = validTarget(player)
			if part then
				local screenDistance = (screen - mouse).Magnitude
				local inFov = Config["360Targeting"] or screenDistance <= Config.FOV
				if inFov then
					local metric
					if Config.TargetPriority == "Lowest Health" then
						metric = player.Character:FindFirstChildOfClass("Humanoid").Health
					elseif Config.TargetPriority == "Distance" then
						metric = distance
					else
						metric = Config.TargetMode == "Closest Distance" and distance or screenDistance
					end
					if bestMetric == nil or metric < bestMetric then
						bestMetric, best = metric, player
					end
				end
			end
		end
		return best
	end

	local function aimAt(player, dt)
		if not player then return end
		local character = player.Character
		local part = character and getPart(character)
		if not part then return end
		local position = part.Position
		local velocity = part.AssemblyLinearVelocity or Vector3.zero
		local prediction = Config.AutoPrediction and Config.Prediction or 0
		local predicted = position + velocity * prediction
		local cameraPosition = Camera.CFrame.Position
		Camera.CFrame = CFrame.lookAt(cameraPosition, predicted)
	end

	local function shouldAim()
		if not Config.Enabled then return false end
		if Config.HoldToAim and not State.Holding then return false end
		return true
	end

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			State.Holding = true
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			State.Holding = false
		end
	end)

	RunService.RenderStepped:Connect(function(dt)
		if not Camera or Camera ~= Workspace.CurrentCamera then Camera = Workspace.CurrentCamera end
		if fovCircle then
			local mouse = getMousePosition()
			fovCircle.Position = mouse
			fovCircle.Radius = Config.FOV
			fovCircle.Visible = Config.ShowFOV and not Config["360Targeting"]
		end
		if not shouldAim() then
			State.Target = nil
			return
		end
		if not State.Target or os.clock() - State.LastSwitch >= Config.TargetSwitchDelay then
			local nextTarget = chooseTarget()
			if nextTarget ~= State.Target then
				State.Target = nextTarget
				State.LastSwitch = os.clock()
			end
		end
		if State.Target then
			local part = validTarget(State.Target)
			if not part then State.Target = nil return end
			aimAt(State.Target, dt)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		if State.Target == player then State.Target = nil end
	end)

	getgenv().__SovereignHubAimbotConfig = Config
	getgenv().__SovereignHubAimbotState = State
end

-- Mark the no-key runtime as initialized after the appended modules are ready.
genv.SovereignHubScriptLoaded = true
if type(_G.__SovereignHubMarkRuntimeReady) == "function" then
	pcall(_G.__SovereignHubMarkRuntimeReady)
end
