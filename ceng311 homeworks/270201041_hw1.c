/*

	Sude Nur Çevik
	270201041

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct dynamic_array
{
	int capacity;
	int size;
	void **elements;
} dynamic_array;

void init_array(dynamic_array *array)
{
	array->capacity = 2;
	array->size = 0;
	array->elements = (void **)malloc(array->capacity * sizeof(void *));

	fill_empty_with_null(array);
}

void put_element(dynamic_array *array, void *element)
{

	array->elements[array->size] = element;
	array->size += 1;

	if (array->size == array->capacity)
	{
		array->capacity *= 2;
		array->elements = (void **)realloc(array->elements, array->capacity * sizeof(void *));
		fill_empty_with_null(array);
	}
}

void remove_element(dynamic_array *array, int position)
{

	slide_elements_one_from(array, position);
	array->size -= 1;

	if (array->size * 2 < array->capacity)
	{
		array->capacity /= 2;
		array->elements = (void **)realloc(array->elements, array->capacity * sizeof(void *));
		fill_empty_with_null(array);
	}
}

void *get_element(dynamic_array *array, int position)
{
	return array->elements[position];
}

typedef struct song
{
	char *name;
	float duration;
} song;

void mainMenu()
{
	printf("\n\n-------------- MAIN MENU --------------");
	printf("\n1- Add a new song");
	printf("\n2- Delete the song");
	printf("\n3- List all songs");
	printf("\n4- Exit");
	printf("\n---------------------------------------");
}

void fill_empty_with_null(dynamic_array *array)
{
	int i;
	for (i = array->size; i < array->capacity; i++)
	{
		array->elements[i] = NULL;
	}
}

void slide_elements_one_from(dynamic_array *array, int position)
{
	int i;
	for (i = position; i < array->size; i++)
	{
		array->elements[i] = array->elements[i + 1];
	}
	array->elements[array->size] = NULL;
}

int get_element_position_by_name(dynamic_array *array, char *name)
{
	int i;
	for (i = 0; i < array->size; i++)
	{
		if (!strcmp(name, (*((struct song *)(array->elements[i]))).name))
		{
			return i;
		}
	}
	return -1;
}

int main()
{

	struct dynamic_array songList;

	init_array(&songList);

	int choice;
	while (1)
	{
		mainMenu();

		printf("\nSize: %d, Capacity: %d", songList.size, songList.capacity);

		printf("\n\nEnter the choice:");
		scanf("%d", &choice);

		if (choice == 1)
		{

			printf("\n----------- Add a new song ------------");

			printf("\nName of song:");
			char *name = (char *)malloc(64 * sizeof(char));
			scanf("%s", name);

			printf("Duration of song:");
			float duration;
			scanf("%f", &duration);

			struct song *newSong = (struct song *)malloc(sizeof(struct song));
			newSong->duration = duration;
			newSong->name = name;

			put_element(&songList, newSong);
		}

		else if (choice == 2)
		{

			printf("\n----------- Delete the song -----------");

			printf("\nName of song that you want to delete:");
			char *name = (char *)malloc(64 * sizeof(char));
			scanf("%s", name);

			int position = get_element_position_by_name(&songList, name);
			if (position != -1)
			{
				free((*((struct song *)(songList.elements[position]))).name);
				free(songList.elements[position]);
				remove_element(&songList, position);
			}
			else
			{
				printf("\nThere is no such a song!");
			}
		}

		else if (choice == 3)
		{

			printf("\n--------- List of all songs -----------");

			int i;
			for (i = 0; i < songList.size; i++)
			{
				struct song *songAtIndex = get_element(&songList, i);

				if (songAtIndex == NULL)
				{
					printf("\nSong %d => NULL", i + 1);
				}
				else
				{
					printf("\nSong %d => name:%s duration:%f", i + 1, songAtIndex->name, songAtIndex->duration);
				}
			}
		}

		else if (choice == 4)
		{
			printf("\n--------------- Exit ------------------");
			int i;
			for (i = 0; i < songList.size; i++)
			{
				free((*((struct song *)(songList.elements[i]))).name);
				free(songList.elements[i]);
			}
			free(songList.elements);
			break;
		}
		else
		{
			continue;
		}
	}

	return 0;
}
