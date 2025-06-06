// ======================================================
// Copyright (c) 2017-2024 the ReSDK_A3 project
// sdk.relicta.ru
// ======================================================

#include <..\GameMode.h>

// Базовая роль для режима GMTraining. Рекомендуется именовать все дочерние роли для этого режима с постфиксом имени режима и префиксом R (Role)
// Пример: RCaveExplorer_GMTraining
class(GMTraining_BasicRole) extends(BasicRole) // BasicRole - базовая роль, от которой унаследованы все возможные роли.
    
    // -----------------------------------------------------------------//
    // -------------------- Базовые настройки роли ---------------------//
    // -----------------------------------------------------------------//
	var(name,"Имя роли");
	var(desc,"Описание роли.");

	// Указывает что роль будет являться ключевой. Ключевые роли имеют более высокий приоритет при случайном распредлении.
	// Установите true требуется для тех ролей, без которых режим GMTraining не сможет полноценно функционировать.
	getter_func(isMainRole,false);

	// Данное свойство потребует смены лица и имени при следующем заходе за любую другую роль. 
	/* 
		Оно нужно для того, чтобы игроки после смерти не заходили за персонажа с таким же именем и лицом как и в предыдущей роли
		Например у жрунов это свойство принимает значение false 
	*/
	getter_func(canStoreNameAndFaceForValidate,true);

	/*
		Сколько человек может зайти за эту роль. При заходе каждого игрока данный счетчик уменьшается на 1.
		Когда счетчик становится равным 0 роль удаляется из списка ролей, которые можно взять
	*/
	var(count,1);
	
	// Создаваемый тип персонажа, если клиент в настройках указал мужской пол.
	var(classMan,"Mob");
	// Создаваемый тип персонажа, если клиент в настройках указал женский пол.
	var(classWoman,"MobWoman");

	// Если данное поле true, то после смерти персонажа игрока сразу вернет в лобби вместо возможности зайти в призрака
	var(returnInLobbyAfterDead,true);

	// Указываем позицию и направление при заходе за эту роль
	// Можно указать префикс pos или rpos если есть конфликт имен рандомной и обычной точки
	// Например: getter_func(spawnLocation,"pos:testspawnpoint");
	getter_func(spawnLocation,null);

	// Режим базового направления персонажа. Работает в связке с spawnLocation. 
	// false - берет направление от стартовой точки, указанной в spawnLocation
	// true - задает случайное направление
	getter_func(useRandomDirOnSpawn,false);

	//Точка привязки (кровать или стул)
	/*
		Может быть:
			- глобальной ссылкой на объект: ref:objectglobalreference
			- именем типа: type:IChair
		Префикс ref или type можно опускать если нет конфликта глобальной ссылки и имени типа
		!!! Указать только connectedTo без spawnLocation невозможно, так как при вставании со стула/кровати
		система должна знать куда поместить персонажа.
	*/
	getter_func(connectedTo,null);

	// ---------------- Управление доступом роли ----------------

	// Специальное условие можно ли взять эту роль до старта раунда
	func(canTakeInLobby)
	{
		objParams_2(_usr,_canPrintErrors);
		true
	};
	// Специальное условие можно ли взять эту роль после старта раунда
	func(canVisibleAfterStart)
	{
		objParams_1(_usr);
		true
	};

	// Список названий ролей дискорда, владельцы которых могут заходить за эту роль. Пустой список означает что роль доступна всем
	getter_func(needDiscordRoles,[]);

	// Список уровней доступа к роли. Пустой список означает что роль доступна всем.
	/*
		Если указаный доступ ACCESS_PLAYER, то доступ может быть для этой роли и всех дочерних (тоесть кто выше или равен этому уровню),
			Например: ACCESS_ADMIN - позволит взять эту роль админам и всем кто выше по статусу 
		Отрицательные значения (прим -ACCESS_PLAYER) означают, что правило относится ТОЛЬКО для этой роли
	*/
	getter_func(roleAccess,[]);



	// ---------------------- Навыки ----------------------

	// Массив базовых атрибутов:
	// Сила (ST), Интеллект (IQ), Ловкость (DX), Здоровье (HT)
    /*
		Форма определения:
			точка с запятой - разделитель определения атрибутов, 
			двоеточие или равно - разделитель имени атрибута и значения, 
			дефис - для указания диапазона числовых значений
	*/
	getter_func(getSkills,"st: 10; dx: 10; iq: 10; ht: 10");

	//Список дополнительных навыков
    /*
        Форма определения такая же как для getSkills:
		точка с запятой - разделитель определения атрибутов, 
		двоеточие или равно - разделитель имени атрибута и значения, 
		дефис - для указания диапазона числовых значений
    */
	func(getOtherSkills) {
		"fight:0;" //навык рукопашного боя
		+ "shield:0;" //навык владения щитами
		+ "fencing:0;" //навык владения фехтовальным оружием
		+ "axe:0;" //навык владения топорами
		+ "baton:0;" //навык валдения дубиной
		+ "spear:0;" //навык владения копьем
		+ "sword:0;" //навык владения мечами
		+ "knife:0;" //навык владения ножами
		+ "whip:0;" //навык владения кнутами

		+ "pistol:0;" //навык владения пистолетами
		+ "rifle:0;" //навык владения винтовками
		+ "shotgun:0;" //навык владения дробовиками
		+ "crossbow:0;" //навык стрельбы из лука

		+ "throw:0;" //навык метания

		+ "chemistry:0;" //навык работы с химией
		+ "alchemy:0;" //навык работы с пещерной химией

		+ "engineering:0;" //навык строительства
		+ "traps:0;" //навык работы с ловушками
		+ "repair:0;" //навык ремонта
		+ "blacksmithing:0;" //навык кузнецкого ремесла
		+ "craft:0;" //навык создания различных предметов

		+ "theft:0;" //навык воровства
		+ "stealth:0;" //навык скрытности
		+ "agility:0;" //навык акробатики
		+ "lockpicking:0;" //навык взлома

		+ "healing:0;" //навык первой помощи
		+ "surgery:0;" //навык хирургии

		+ "cavelore:0;" //навык знания пещер

		+ "cooking:0;" //навык готовки
		+ "farming:0;" //навык фермерства
	};

	// Функция, в которой можно выдать экипировку персонажу
	func(getEquipment)
	{
		objParams_1(_mob);
		/*
			Чтобы создать пердмет в слоте персонажа используйте createItemInInventory
			Чтобы создать предмет внутри контейнера (одежды, рюкзака) используйте createItemInContainer
		*/
	};

	// -----------------------------------------------------------------//
    // ------------------ Основные функции состояний -------------------//
    // -----------------------------------------------------------------//

	
	// Вызывается когда клиент зашёл за роль и полностью загрузился
	func(onAssigned)
	{
		//_mob - персонаж, _usr - клиент
		objParams_2(_mob,_usr);
		
		// Тут вызывается код когда клиент уже назначился за эту роль из лобби
		// Допускается любая пользовательская логика, например установить голод
	};

	// Функция, вызывающаяся когда умирает персонаж, зашедший за эту роль с самого начала
	/*
		Если игрок зашёл за персонажа за роль A и потом получил роль B,
		то в этом случае при смерти будет вызван onDeadBasic() от объекта A 
	*/
	func(onDeadBasic)
	{
		objParams_2(_mob,_usr);

		// Установка таймера призраку (в секундах)
		// работает если returnInLobbyAfterDead возвращает false
		// callFuncParams(_usr,setDeadTimeout,30);
	};

	// Функция, вызывающаяся когда умирает персонаж владеющий этой ролью со старта.
	/*
		Если игрок зашёл за персонажа за роль A и потом получил роль B,
		то в этом случае при смерти будет вызван onDeadBasic() от объекта B 
	*/
	func(onDead)
	{
		objParams_2(_mob,_usr);
	};

	// Вызывается при конце игры за текущую роль (если человек выжил за нее)
	// В большинстве случаев используется onEndgameBasic например для начисления очков.
	/* 
		Логика и принцип работы аналогичен onDead и onDeadBasic
		*Basic-вариант вызывается для роли, с которой стартовал персонаж
		обычный вариант вызывается для роли, которую имел персонаж в момент смерти
	*/
	func(onEndgame)
	{
		objParams_2(_mob,_usr);
	};

	// Вызывается при конце раунда для персонажа, владеющего этой ролью со старта.
	func(onEndgameBasic)
	{
		objParams_2(_mob,_usr);
	};

	// -----------------------------------------------------------------//
    // ---------------------- Настройки антагониста --------------------//
    // -----------------------------------------------------------------//
	
	// Небольшое примечание:
	// Обычно роли, помеченные как главные (isMainRole) не должны быть антагонистами
	// Пример: наверное было бы неинтересно, если Голова стал бы агентом НА, который без труда разрушает собственное поселение... 


	// Может ли быть роль полноценным антагонистом
	func(canBeFullAntag)
	{
		objParams_1(_usr); // _usr - клиент, игрок
		true // Исходя из примечания выше, целесообразнее было бы написать: !callSelf(isMainRole)
	};

	// Может ли быть данная роль скрытым антагонистом
	func(canBeHiddenAntag)
	{
		objParams_1(_usr); // _usr - клиент, игрок
		true
	};
	
endclass

/*
	Определяем роли, унаследованные от GMTraining_BasicRole

class(RDebugRole_GMTraining) extends(GMTraining_BasicRole)
	//change if need
	var(name,"Debug role");
	var(desc,"For debugging");

	// Needs:
	// Setup main role, count, serialization, ghosted (isMainRole, count, canStoreNameAndFaceForValidate, returnInLobbyAfterDead)
	// Setup spawn and bed/chair if needed (spawnLocation, useRandomDirOnSpawn, connectedTo)
	// Setup skills and otherskills (getSkills, getOtherSkills)
	// Access settings: canTakeInLobby, canVisibleAfterStart 
	// 		(optional) Special access: needDiscordRoles, roleAccess
	// Generic join/dead events: onAssigned, onDeadBasic, onEndgameBasic
	//		(optional) Custom events: onDead, onEndgame
	// (optional) Antag logics (Can be antagonist???) (canBeFullAntag, canBeHiddenAntag)

endclass

*/