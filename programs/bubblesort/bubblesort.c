#include <stdio.h>
#include <stdlib.h>

#define TRUE 1
#define FALSE 0

void bubblesort(int* array, int array_size)
{
    int pos_troca = 0;
    int troca = TRUE;
    int qtd_elementos = array_size - 1;

    while (troca)
    {
        troca = FALSE;
        for (int i = 0; i < qtd_elementos; i++)
        {
            if (array[i] > array[i + 1])
            {
                int temp = array[i];
                array[i] = array[i + 1];
                array[i + 1] = temp;
                troca = TRUE;
                pos_troca = i;
            }
        }
        qtd_elementos = pos_troca;
    }
}

void printArray(int* array, int array_size)
{
    printf("\n");
    for (int i = 0; i < array_size; i++)
    {
        printf("%d ", array[i]);
    }
    printf("\n");
}

#define ARRAY_SIZE 10

int main(int argc, char *argv[])
{
    int array[ARRAY_SIZE] = { 9, 8, 7, 6, 5, 4, 3, 2, 1 ,0 };
    printf("Array desordenado: ");
    printArray(array, ARRAY_SIZE);
    bubblesort(array, ARRAY_SIZE);
    printf("\nArray ordenado: ");
    printArray(array, ARRAY_SIZE);
    return EXIT_SUCCESS;
}
