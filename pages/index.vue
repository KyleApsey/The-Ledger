<script>
export default {
  mounted() {
    if (isSessionValid()) {
      this.$router.replace('/checklist')
    } else {
      this.$router.replace('/pin')
    }
  },
}
</script>

<template>
  <div />
</template>
